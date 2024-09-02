{ lib
, stdenv
, fetchFromGitHub
, cmake
, gnuradio
, spdlog
, gmp
, boost
, volk
, python
}:

stdenv.mkDerivation rec {
  pname = "gr-satellites";
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "daniestevez";
    repo = "gr-satellites";
    rev = "v${version}";
    hash = "sha256-ZQuTgvpcy6+Vk+eoEOTT7FRslFdc8R4qMFjNkID4bZ8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    python
  ];

  buildInputs = [
    gnuradio
    spdlog
    gmp
    boost
    volk
    python.pkgs.pybind11
    python.pkgs.numpy
  ];

  meta = with lib; {
    description = "GNU Radio decoder for Amateur satellites";
    homepage = "https://github.com/daniestevez/gr-satellites.git";
    changelog = "https://github.com/daniestevez/gr-satellites/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-satellites";
    platforms = platforms.all;
  };
}
