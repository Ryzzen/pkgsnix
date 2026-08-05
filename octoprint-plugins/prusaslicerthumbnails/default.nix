# See ../bltouch/default.nix for why this takes `buildPlugin` and must be
# callPackage'd from octoprint.python.pkgs rather than pkgs.python3Packages.
{
  lib,
  buildPlugin,
  fetchFromGitHub,
}:

buildPlugin rec {
  pname = "prusaslicerthumbnails";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-PrusaSlicerThumbnails";
    rev = version;
    hash = "sha256-NjL3CJkuUnkYJSIFej0JrkYxW9j+BUJNNqd3p2XLyL4=";
  };

  meta = {
    description = "Extracts embedded thumbnails from slicer-generated gcode for display in OctoPrint";
    homepage = "https://github.com/jneilliii/OctoPrint-PrusaSlicerThumbnails";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
