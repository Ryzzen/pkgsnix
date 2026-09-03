# Control software for the BH3 rig: an Olympus BH3 microscope with a Canon EOS
# 5D Mark II on the trinocular phototube. Live view with focus scoring and
# peaking, exposure control, and tethered capture with a keep-or-discard review.
# Upstream: github:Ryzzen/MicroscopeControl (PySide6 + python-gphoto2, hatchling).
#
# Canon's EDSDK is Windows/macOS only, so libgphoto2 is the whole field on
# Linux; `python3Packages.gphoto2` pulls it in. Everything else comes from the
# 25.05 base set, so this adds no new closure beyond pyside6.
#
# Two notes on getting the camera to talk at all, neither of which this
# derivation can fix for you:
#
#   * libgphoto2's own udev rules set GROUP="camera", and NixOS does not create
#     that group, so the device node stays root:root. A `uaccess` rule is
#     simpler -- see the project README.
#   * If gvfs is running it claims the camera on enumeration and libgphoto2
#     gets -53. The app detects and explains that case specifically.
{
  lib,
  python3Packages,
  fetchFromGitHub,
  qt6,
  makeDesktopItem,
  copyDesktopItems,
}:
python3Packages.buildPythonApplication rec {
  pname = "microscope-control";
  version = "0-unstable-2026-09-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Ryzzen";
    repo = "MicroscopeControl";
    rev = "2b93dff7822e35201c3b4d8d0f0bb5f348b95261";
    hash = "sha256-YkmhryAJhVuzFSbW/u8jGmiu4jyEuRkasppdqXvKCCA=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    pyside6
    numpy
    gphoto2 # python-gphoto2; brings libgphoto2 with it
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    copyDesktopItems
  ];

  # wrapQtAppsHook reads qtPluginPrefix out of qtbase's setup hook and fails
  # outright without it. pyside6 ships its own copy of the Qt libraries, so
  # this is here for the hook's benefit rather than to link against.
  buildInputs = [ qt6.qtbase ];

  # buildPythonApplication makes its own wrapper, so wrapQtAppsHook's would be
  # discarded. Folding qtWrapperArgs into makeWrapperArgs is the nixpkgs
  # pattern for Qt apps built by a Python builder -- without it the app starts
  # with no QPA platform plugin and dies looking for xcb/wayland.
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  # The desktop entry and icon live here rather than upstream because upstream
  # ships neither; if they move into the repo later, drop these and let
  # copyDesktopItems pick them out of the source instead.
  desktopItems = [
    (makeDesktopItem {
      name = "microscope-control";
      exec = "microscope-control";
      icon = "microscope-control";
      desktopName = "MicroscopeControl";
      genericName = "Microscope camera control";
      comment = "Live view, focus aids and tethered capture for the BH3 rig";
      # One main category only. Graphics and Science are both top-level, and
      # listing two makes the entry appear twice in the applications menu --
      # desktop-file-validate warns about exactly this. Photography is a
      # subcategory of Graphics, so the pair is well-formed.
      categories = [
        "Graphics"
        "Photography"
      ];
      keywords = [
        "microscope"
        "camera"
        "gphoto"
        "canon"
        "tethered"
        "focus"
      ];
    })
  ];

  postInstall = ''
    install -Dm444 ${./microscope-control.svg} \
      $out/share/icons/hicolor/scalable/apps/microscope-control.svg
  '';

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  # Only the pure-numpy logic is covered -- focus metrics, the peaking
  # threshold, exposure classification, the EXIF orientation patch. Those are
  # the parts that fail *quietly*: a broken metric still shows a plausible
  # number. The Qt layer fails loudly enough not to need a headless harness in
  # the build.
  enabledTestPaths = [ "tests/" ];
  pythonImportsCheck = [ "microscope_control" ];

  meta = {
    description = "Live view, focus aids and tethered capture for a Canon EOS on an Olympus BH3";
    homepage = "https://github.com/Ryzzen/MicroscopeControl";
    platforms = lib.platforms.linux;
    mainProgram = "microscope-control";
  };
}
