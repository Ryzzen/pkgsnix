{ lib, pythonPackages, fetchFromGitHub, enum_tools, quokka_project, PyQBDI, triton-library }:

pythonPackages.buildPythonPackage rec {
  pname = "tritondse";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "quarkslab";
    repo = "tritondse";
    rev = "v0.1.8";
    sha256 = "sha256-sKkSUXxSNodu5wAL8MUFR6H5QoUJN0poRiTaUc64AC4=";
  };

  nativeBuildInputs = [ pythonPackages.setuptools ];

  propagatedBuildInputs = [
    enum_tools
    quokka_project
    pythonPackages.cle
    PyQBDI
    pythonPackages.lief
    triton-library
  ];
}
