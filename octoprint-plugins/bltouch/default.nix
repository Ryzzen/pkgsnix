# Called with octoprint's OWN python package set, not pkgs.python3Packages:
#   octoprint-bltouch = pkgs.octoprint.python.pkgs.callPackage ./octoprint-plugins/bltouch { };
# That set is where nixpkgs defines `buildPlugin` (buildPythonPackage with
# octoprint propagated and tests disabled), and it pins the same interpreter
# OctoPrint runs on — a plugin built against any other python will not load.
{
  lib,
  buildPlugin,
  fetchFromGitHub,
}:

buildPlugin rec {
  pname = "bltouch";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-BLTouch";
    rev = version;
    hash = "sha256-bG997uLmB/+oXeSQG/lQjKcwBAz4OeAl3kEE8fKQJi4=";
  };

  meta = {
    description = "Control a BLTouch auto bed levelling probe from the OctoPrint UI";
    homepage = "https://github.com/jneilliii/OctoPrint-BLTouch";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
