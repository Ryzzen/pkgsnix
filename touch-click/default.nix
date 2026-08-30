# Injects pointer clicks for touchscreen taps that land on windows which never
# bind wl_touch. See touch-click.py for why this exists and why it is selective
# rather than a blanket touchscreen grab.
{
  lib,
  python3,
  writeScriptBin,
}:
let
  py = python3.withPackages (ps: [ ps.evdev ]);
in
writeScriptBin "touch-click" ''
  #!${py}/bin/python3
  ${builtins.readFile ./touch-click.py}
''
// {
  meta = {
    description = "Synthesise pointer clicks from touchscreen taps for clients without wl_touch";
    platforms = lib.platforms.linux;
    mainProgram = "touch-click";
  };
}
