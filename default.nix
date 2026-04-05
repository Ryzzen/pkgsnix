# Can build using 'nix build .#example';
{ pkgs, ... }:
{
  # example = pkgs.callPackage ./example { };
  # libtriton = pkgs.callPackage ./triton { };
  bata24-gef = pkgs.callPackage ./bata24-gef { };
  ghidra-extensions = pkgs.callPackage ./ghidra-extensions { ghidra = pkgs.ghidra-bin; };
  gr-satellites = pkgs.callPackage ./gnuradio-blocks/gr-satellites {
    gnuradio = pkgs.gnuradio.unwrapped;
    python = pkgs.gnuradio.python;
  };
  gr-aistx = pkgs.callPackage ./gnuradio-blocks/gr-aistx { };
  rusthound = pkgs.callPackage ./rusthound { };
  ida-free = pkgs.callPackage ./ida-free { };
  ida-pro-jailed = pkgs.callPackage ./ida-pro { };
  # binwalk = with pkgs.python3Packages; callPackage ./binwalk {};
  xpack-riscv-gcc = pkgs.callPackage ./xpack-riscv-gcc { };
  wchisp = pkgs.callPackage ./wchisp { };
  wlink = pkgs.callPackage ./wlink { };
  nrf-connect = pkgs.callPackage ./nrf-connect { };
  mirage-bt = pkgs.callPackage ./mirage-bt { };
  binaryninja-free = pkgs.qt6Packages.callPackage ./binaryninja-free { };
  binaryninja-pro = pkgs.qt6Packages.callPackage ./binaryninja-pro { };
  objection = with pkgs.python3Packages; callPackage ./objection { };
  allyourbase = pkgs.callPackage ./allyourbase { };
  ghidrassist = pkgs.callPackage ./ghidra_ghidrassist {
    buildGhidraExtension = pkgs.ghidra.buildGhidraExtension;
  };
}
