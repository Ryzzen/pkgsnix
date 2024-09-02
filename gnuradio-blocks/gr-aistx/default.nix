{ lib
, stdenv
, fetchFromGitHub
, cmake
, gnuradio3_8
, pkg-config
, boost
, spdlog
, gmp
, volk
, cppunit
, log4cpp
, thrift
, python311Packages
, fftwFloat
, swig
}:

stdenv.mkDerivation rec {
  pname = "gr-aistx";
  version = "3.8-port";

  src = fetchFromGitHub {
    owner = "bmagistro";
    repo = "gr-aistx";
    rev = "gnuradio-${version}";
    hash = "sha256-OEfRTGYBWcqP84PM4XXwNc7BlInqjE78/uHFLMLfv74=";
  };

  nativeBuildInputs = [
    cmake
	pkg-config
	boost
	gnuradio3_8
	spdlog
	gmp
	volk
	cppunit
	log4cpp
	thrift
	python311Packages.thrift	
	fftwFloat
	swig
  ];

  meta = with lib; {
    description = "Toolkit for research purposes in AIS. See the website for the paper";
    homepage = "https://github.com/bmagistro/gr-aistx.git";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "gr-aistx";
    platforms = platforms.all;
  };
}
