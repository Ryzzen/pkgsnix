"""Synthesise pointer clicks from touchscreen taps.

Some Wayland clients never bind wl_touch — kitty is the one that prompted this;
foot has the same gap — so the compositor delivers touch events they simply do
not listen for. Taps are not swallowed, they are never received, and no amount
of client configuration changes that. Hyprland has no touch-to-pointer
emulation of its own (its touchdevice section is only enabled/output/transform),
so the gap has to be filled from outside.

This does that SELECTIVELY, which is the whole design point. The obvious
implementation grabs the touchscreen outright and turns every touch into a
mouse event, but that would break every app that handles touch properly:
browsers lose kick-scrolling and pinch-zoom, and the compositor loses its own
touch gestures. Instead the device is left ungrabbed, so touch keeps flowing to
everyone as before, and a click is injected only when the tap lands on a window
whose class is on the allow-list. Touch-blind apps gain clicks; touch-aware apps
are untouched.

Nothing double-fires: an app on the allow-list is on it precisely because it
ignores the touch event, so the injected click is the only input it sees.
"""

import argparse
import json
import os
import socket
import subprocess
import sys
import time

from evdev import InputDevice, UInput, ecodes, list_devices


def log(msg):
    print(f"touch-click: {msg}", file=sys.stderr, flush=True)


# ── Hyprland IPC ────────────────────────────────────────────────────────
# Spoken directly over the socket rather than by shelling out to hyprctl: a tap
# needs two round trips (position the cursor, ask what is under it) and paying
# two process spawns each time is latency the user would feel as lag.


def _socket_path():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not sig:
        raise RuntimeError("HYPRLAND_INSTANCE_SIGNATURE unset — not in a Hyprland session")
    rt = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    return f"{rt}/hypr/{sig}/.socket.sock"


def hypr(command):
    """Send one command, return the reply as text."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(_socket_path())
        s.sendall(command.encode())
        chunks = []
        while True:
            c = s.recv(8192)
            if not c:
                break
            chunks.append(c)
    return b"".join(chunks).decode(errors="replace")


def hypr_json(what):
    try:
        return json.loads(hypr(f"j/{what}"))
    except (ValueError, OSError) as e:
        log(f"IPC {what} failed: {e}")
        return None


# ── Device discovery ────────────────────────────────────────────────────


def find_touchscreen(name_match):
    """First device whose name contains name_match and which reports MT positions."""
    for path in list_devices():
        try:
            dev = InputDevice(path)
        except OSError:
            continue
        caps = dev.capabilities().get(ecodes.EV_ABS, [])
        codes = [c for c, _ in caps]
        if name_match.lower() in dev.name.lower() and ecodes.ABS_MT_POSITION_X in codes:
            return dev
        dev.close()
    return None


def abs_range(dev, code):
    for c, info in dev.capabilities().get(ecodes.EV_ABS, []):
        if c == code:
            return info.min, info.max
    raise RuntimeError(f"device exposes no absinfo for code {code}")


# ── Geometry ────────────────────────────────────────────────────────────


def layer_at(lx, ly):
    """Namespace of the topmost input-taking layer surface over this point.

    Layer surfaces are not windows, so "which window is active" cannot see them
    and a click injected blindly lands on whatever is stacked above. That is what
    doubled every keystroke typed on the on-screen keyboard: wvkbd emitted the
    key for the touch, and again for the click landing on it.

    Level 0 and 1 are background and bottom - the wallpaper lives there and takes
    no input. 2 and 3 are top and overlay, where anything interactive sits.
    Levels ascend and, within one, later entries are stacked on top, so the last
    match wins. Also returns every mapped namespace, which is how a tap that
    lands nowhere near an open launcher can still be recognised as meaning
    "dismiss it".
    """
    data = hypr_json("layers") or {}
    top = None
    mapped = set()
    for mon in data.values():
        levels = (mon.get("levels") or {})
        for level in sorted(levels, key=lambda k: int(k) if k.isdigit() else 0):
            if not level.isdigit() or int(level) < 2:
                continue
            for l in levels[level]:
                mapped.add(l["namespace"].lower())
                if (
                    l["x"] <= lx < l["x"] + l["w"]
                    and l["y"] <= ly < l["y"] + l["h"]
                ):
                    top = l["namespace"]
    return top, mapped


def touch_monitor():
    """Logical geometry of the monitor the panel is attached to.

    Logical, not physical: Hyprland positions the cursor in layout coordinates,
    so a 1920x1280 panel at scale 1.6 is a 1200x800 surface to aim at. Reading
    width/scale rather than assuming keeps this correct if the scale changes.
    """
    mons = hypr_json("monitors")
    if not mons:
        return None
    mon = next((m for m in mons if m.get("focused")), mons[0])
    scale = mon.get("scale") or 1.0
    return {
        "x": mon["x"],
        "y": mon["y"],
        "w": mon["width"] / scale,
        "h": mon["height"] / scale,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--device-name",
        default="Finger",
        help="substring of the touchscreen's device name (default: Finger)",
    )
    ap.add_argument(
        "--classes",
        default="kitty",
        help="comma-separated window classes to inject clicks for (default: kitty)",
    )
    ap.add_argument(
        "--layer-classes",
        default="rofi",
        help="layer-shell namespaces that need synthetic clicks (default: rofi)",
    )
    args = ap.parse_args()

    allow = {c.strip().lower() for c in args.classes.split(",") if c.strip()}
    layer_allow = {c.strip().lower() for c in args.layer_classes.split(",") if c.strip()}
    log(f"injecting clicks for windows {sorted(allow)} and layers {sorted(layer_allow)}")

    dev = None
    for _ in range(30):
        dev = find_touchscreen(args.device_name)
        if dev:
            break
        time.sleep(1)
    if not dev:
        log(f"no touchscreen matching {args.device_name!r}; giving up")
        return 1
    log(f"touchscreen: {dev.name} ({dev.path})")

    xmin, xmax = abs_range(dev, ecodes.ABS_MT_POSITION_X)
    ymin, ymax = abs_range(dev, ecodes.ABS_MT_POSITION_Y)
    xspan = max(1, xmax - xmin)
    yspan = max(1, ymax - ymin)

    # Deliberately NOT dev.grab(): see the module docstring. Touch must keep
    # reaching the apps that understand it.
    # REL_X/REL_Y are declared but never emitted, and that is not an oversight:
    # libinput refuses to treat a button-only device as a pointer, so without an
    # axis the virtual device is created, shows up in /proc/bus/input/devices,
    # and is then ignored by the compositor - clicks go nowhere with no error
    # anywhere. Motion is done through Hyprland's IPC, so the axes only need to
    # exist, not to carry anything.
    ui = UInput(
        {
            ecodes.EV_KEY: [ecodes.BTN_LEFT],
            ecodes.EV_REL: [ecodes.REL_X, ecodes.REL_Y, ecodes.REL_WHEEL],
        },
        name="touch-click",
    )

    mon = touch_monitor()
    if not mon:
        log("could not read monitor geometry; giving up")
        return 1

    # Logical pixels of finger travel per wheel click. Wheel events are discrete,
    # so travel is accumulated and spent a click at a time; the remainder is kept
    # rather than dropped, otherwise slow scrolling would never reach a click.
    SCROLL_STEP = 32

    contacts = {}       # slot -> {"x", "y", "on"}
    slot = 0
    pressed = False     # holding BTN_LEFT
    fresh = False       # slot 0 went down since the last SYN
    scroll_prev = None  # last mean-y of a two-finger gesture, in logical px
    scroll_acc = 0.0    # unspent travel
    scroll_ok = False   # gesture began over something we may scroll

    def contact(sl):
        return contacts.setdefault(sl, {"x": None, "y": None, "on": False})

    def to_logical(rx, ry):
        return (
            mon["x"] + (rx - xmin) / xspan * mon["w"],
            mon["y"] + (ry - ymin) / yspan * mon["h"],
        )

    def targetable(lx, ly):
        """Should this point get a synthetic click?"""
        ns, mapped = layer_at(lx, ly)

        # A listed layer is open, but the tap landed somewhere else. rofi's own
        # click-to-exit cannot help here: its surface is only the centred box
        # (measured 480x355 on a 1200x800 screen), so "outside" is not on its
        # surface at all and it never hears the tap. Dismiss it instead, and
        # swallow the tap rather than passing a click to whatever is underneath -
        # clicking away should close the launcher, not press something behind it.
        #
        # Killing by namespace assumes the namespace matches the process name,
        # which holds for rofi. A layer where it does not would simply not close.
        stray = (mapped & layer_allow) - ({ns.lower()} if ns else set())
        if stray:
            for proc in stray:
                subprocess.Popen(
                    ["pkill", "-x", proc],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            return False

        if ns is not None:
            # A layer is in the way. Most take touch themselves - the bar, the
            # on-screen keyboard - and clicking them would double the input, so
            # leave those strictly alone. The listed ones are layer surfaces that
            # never bind wl_touch, rofi being the case in point: it is a layer,
            # so no window class describes it, and without this a tablet cannot
            # pick an entry, cannot dismiss it by tapping away, and cannot even
            # reach the bar underneath, because rofi takes the touch and does
            # nothing with it.
            if ns.lower() not in layer_allow:
                return False
            try:
                hypr(f"/dispatch movecursor {int(lx)} {int(ly)}")
            except OSError as e:
                log(f"IPC failed mid-touch: {e}")
                return False
            return True
        try:
            hypr(f"/dispatch movecursor {int(lx)} {int(ly)}")
            win = hypr_json("activewindow") or {}
        except OSError as e:
            log(f"IPC failed mid-touch: {e}")
            return False
        return (win.get("class") or "").lower() in allow

    for ev in dev.read_loop():
        if ev.type == ecodes.EV_ABS:
            if ev.code == ecodes.ABS_MT_SLOT:
                slot = ev.value
            elif ev.code == ecodes.ABS_MT_TRACKING_ID:
                c = contact(slot)
                c["on"] = ev.value != -1
                if c["on"] and slot == 0:
                    fresh = True
            elif ev.code == ecodes.ABS_MT_POSITION_X:
                contact(slot)["x"] = ev.value
            elif ev.code == ecodes.ABS_MT_POSITION_Y:
                contact(slot)["y"] = ev.value

        elif ev.type == ecodes.EV_SYN and ev.code == ecodes.SYN_REPORT:
            live = [
                c for c in contacts.values()
                if c["on"] and c["x"] is not None and c["y"] is not None
            ]

            if len(live) >= 2:
                # Two fingers means scroll, never click. Any press already taken
                # by the first finger is let go here, so a scroll that starts a
                # fraction of a second after touchdown does not leave a drag
                # selection behind it.
                if pressed:
                    ui.write(ecodes.EV_KEY, ecodes.BTN_LEFT, 0)
                    ui.syn()
                    pressed = False
                fresh = False

                mean_y = sum(c["y"] for c in live[:2]) / 2
                mean_x = sum(c["x"] for c in live[:2]) / 2
                _, ly = to_logical(mean_x, mean_y)
                lx, _ = to_logical(mean_x, mean_y)

                if scroll_prev is None:
                    scroll_prev, scroll_acc = ly, 0.0
                    scroll_ok = targetable(lx, ly)
                elif scroll_ok:
                    scroll_acc += ly - scroll_prev
                    scroll_prev = ly
                    while abs(scroll_acc) >= SCROLL_STEP:
                        # Traditional, matching this machine's touchpad
                        # (natural_scroll is off): fingers moving down scrolls
                        # the view down, which is a negative wheel step.
                        step = -1 if scroll_acc > 0 else 1
                        ui.write(ecodes.EV_REL, ecodes.REL_WHEEL, step)
                        ui.syn()
                        scroll_acc -= SCROLL_STEP if scroll_acc > 0 else -SCROLL_STEP
                else:
                    scroll_prev = ly

            elif len(live) == 1:
                scroll_prev, scroll_acc = None, 0.0
                c = live[0]
                lx, ly = to_logical(c["x"], c["y"])
                if fresh:
                    fresh = False
                    if targetable(lx, ly):
                        ui.write(ecodes.EV_KEY, ecodes.BTN_LEFT, 1)
                        ui.syn()
                        pressed = True
                elif pressed:
                    # Drag: keep the cursor under the finger so selection works.
                    try:
                        hypr(f"/dispatch movecursor {int(lx)} {int(ly)}")
                    except OSError:
                        pass

            else:
                fresh = False
                scroll_prev, scroll_acc = None, 0.0
                if pressed:
                    ui.write(ecodes.EV_KEY, ecodes.BTN_LEFT, 0)
                    ui.syn()
                    pressed = False

    return 0


if __name__ == "__main__":
    sys.exit(main())
