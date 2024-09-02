{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mirage";
  version = "unstable-2022-11-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "RCayre";
    repo = "mirage";
    rev = "f73f6c4442e4bfd239eb5caf5e1283c125d37db9";
    hash = "sha256-MnC0n+Y2iWYTltVUetEhuvSfSkEVzfVpm38n0GO6d3A=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.keyboard
    python3.pkgs.terminaltables
    python3.pkgs.pyusb
    python3.pkgs.pyserial
    python3.pkgs.pycryptodomex
    python3.pkgs.psutil
    python3.pkgs.scapy
    python3.pkgs.matplotlib
  ];

  pythonImportsCheck = [ "mirage" ];

  meta = with lib; {
    description = "Mirage is a powerful and modular framework dedicated to the security analysis of wireless communications";
    homepage = "https://github.com/RCayre/mirage.git";
    changelog = "https://github.com/RCayre/mirage/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ryzzen ];
    mainProgram = "mirage";
  };
}
