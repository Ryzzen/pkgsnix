{ lib, pkgs, pythonPackages, fetchFromGitHub, enum_tools, quokka_project }:

pythonPackages.buildPythonPackage rec {
	pname = "PyQBDI";
	version = "0.10.0";
	format = "wheel";

	src = pythonPackages.fetchPypi {
		inherit pname version format;
		python = "cp311";
		abi = "cp311";
		platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
		dist = "cp311";
		sha256 = "sha256-5OqpaWJq6yPNhxOH3EC9LC7UArpFrFDWAZLc+IbkoY4=";
	};

	nativeBuildInputs = [ pkgs.autoPatchelfHook ];
}
