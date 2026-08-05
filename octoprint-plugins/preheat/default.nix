# See ../bltouch/default.nix for why this takes `buildPlugin` and must be
# callPackage'd from octoprint.python.pkgs rather than pkgs.python3Packages.
{
  lib,
  buildPlugin,
  fetchFromGitHub,
}:

buildPlugin rec {
  pname = "preheat";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "marian42";
    repo = "octoprint-preheat";
    rev = version;
    hash = "sha256-q7WbSfwLfEWMdJ/tze8FBSWt7cchRICMyB1cXNnPspo=";
  };

  meta = {
    description = "Adds a button to preheat the printer to the temperatures in the loaded gcode";
    homepage = "https://github.com/marian42/octoprint-preheat";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
