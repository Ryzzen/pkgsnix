{ lib, pkgs, pythonPackages, fetchFromGitHub }:

pythonPackages.buildPythonPackage rec {
	pname = "triton_library";
	version = "1.0.0rc2";
	format = "wheel";

	src = pythonPackages.fetchPypi {
		inherit pname version format;
		python = "cp311";
		abi = "cp311";
		platform = "manylinux_2_24_x86_64";
		dist = "cp311";
		sha256 = "sha256-46+vjYJhyTK5jD7xeZN5X4xmEY/lB26WZV6p9smfw6Y=";
	};

	nativeBuildInputs = [ pkgs.autoPatchelfHook ];
}
