{ lib, pythonPackages, fetchFromGitHub }:

pythonPackages.buildPythonPackage rec {
	pname = "quokka_project";
	version = "0.5.4";
	format = "wheel";

	src = pythonPackages.fetchPypi {
		inherit pname version format;
		python = "py3";
		dist = "py3";
		sha256 = "sha256-CXNkHg2eMHEt3mTF8fV9jmaxe0nBSQHHNwP+obotmJs=";
	};

	propagatedBuildInputs = [
		pythonPackages.capstone
		pythonPackages.networkx
		pythonPackages.protobuf
	];
}
