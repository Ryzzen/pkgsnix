{ lib, pythonPackages, fetchFromGitHub }:

pythonPackages.buildPythonPackage rec {
	pname = "enum_tools";
	version = "0.11.0";
	format = "wheel";

	src = pythonPackages.fetchPypi {
		inherit pname version format;
		python = "py3";
		dist = "py3";
		sha256 = "sha256-nnYYb/T9F5imSoVdM04kWn0rZ5cMQAKazM/wbFi/BTU=";
	};

	propagatedBuildInputs = [ pythonPackages.pygments pythonPackages.typing-extensions ];
}
