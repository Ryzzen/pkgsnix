{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "allyourbase";
  version = "unstable-2025-03-07";

  src = fetchFromGitHub {
    owner = "8051Enthusiast";
    repo = "allyourbase";
    rev = "78e98f7a592c5bfdb52590bdd26139202b602100";
    hash = "sha256-CIeet51wG6daSn5Ek4mB9uQqqDOoYdYOv/qdgTcWpHk=";
  };

  format = "other";

  buildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
  ];

  installPhase = ''
    install -Dm755 allyourbase.py $out/bin/allyourbase
  '';

  meta = {
    description = "Finds the base address of a firmware by comparing string addresses with target pointer addresses";
    homepage = "https://github.com/8051Enthusiast/allyourbase";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Ryzzen ];
    mainProgram = "allyourbase";
    platforms = lib.platforms.all;
  };
}
