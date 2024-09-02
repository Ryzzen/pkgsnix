{ lib
, python3
, fetchFromGitHub
, bloodhound
}:

python3.pkgs.buildPythonApplication rec {
  pname = "net-exec";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Pennyw0rth";
    repo = "NetExec";
    rev = "v${version}";
    hash = "sha256-cNkZoIdfrKs5ZvHGKGBybCWGwA6C4rqjCOEM+pX70S8=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aardwolf
    aioconsole
    aiosqlite
    asyauth
    beautifulsoup4
    bloodhound
#    dploot
    dsinternals
    impacket
    lsassy
    masky
    minikerberos
    msgpack
    neo4j
    oscrypto
    paramiko
    pyasn1-modules
    pylnk3
    pypsrp
    pypykatz
#    pyreadline
    python-libnmap
    pywerview
    requests
#    resource
    rich
#    ruff
    sqlalchemy
    termcolor
    terminaltables
    xmltodict
  ];

  pythonImportsCheck = [ "netexec" ];

  meta = with lib; {
    description = "The Network Execution Tool";
    homepage = "https://github.com/Pennyw0rth/NetExec.git";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    mainProgram = "net-exec";
  };
}
