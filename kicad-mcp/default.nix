# MCP server exposing KiCad projects/tooling to Claude Code.
# Upstream: github:lamaalrajih/kicad-mcp (Python, hatchling, fastmcp).
#
# Built against `unstable.python3Packages` because `fastmcp` is absent from the
# 25.05 base channel; keeping the whole closure on one interpreter avoids
# mixing two python3 sets. Exposes a `kicad-mcp` console script (stdio MCP).
{ pkgs, ... }:
let
  py = pkgs.unstable.python3Packages;
in
py.buildPythonApplication rec {
  pname = "kicad-mcp";
  version = "0-unstable-2026-06-11";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "lamaalrajih";
    repo = "kicad-mcp";
    rev = "98c9ea41cb393393a8bafd157a93e84431e00afb";
    hash = "sha256-45+uc0QMqQKCRkmUOq/+F36Ap4Ab3iiJy0kTqDz2SeI=";
  };

  build-system = [ py.hatchling ];

  dependencies = with py; [
    mcp
    fastmcp
    pandas
    pyyaml
    defusedxml
  ];

  # Put `kicad-cli` on the server's PATH so DRC / BOM export / netlist tools
  # work. The server resolves it via `shutil.which`, and the hardcoded Linux
  # fallbacks (/usr/bin, /opt/kicad) don't exist on NixOS — so PATH is the only
  # reliable handle. Reuses `unstable.kicad`, which the consumer typically
  # already installs, so it adds no extra closure there.
  makeWrapperArgs = [
    "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.unstable.kicad ]}"
  ];

  # Pure-python MCP server with no test deps wired here.
  doCheck = false;
  pythonImportsCheck = [ "kicad_mcp" ];

  meta = {
    description = "MCP server for interacting with KiCad projects";
    homepage = "https://github.com/lamaalrajih/kicad-mcp";
    mainProgram = "kicad-mcp";
  };
}
