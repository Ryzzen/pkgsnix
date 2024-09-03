{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  gdb,
  python311,
  bintools-unwrapped,
  file,
  ps,
  git,
  coreutils,
  one_gadget,
}:

let
  pythonPath =
    with python311.pkgs;
    makePythonPath [
      keystone-engine
      unicorn
      capstone
      ropper
      crccheck
      tqdm
    ];

in
stdenv.mkDerivation rec {
  pname = "gef";
  version = "bata24";

  src = fetchFromGitHub {
    owner = "bata24";
    repo = "gef";
    rev = "dev";
    sha256 = "sha256-oRE3HSze4W3r11v4MDUg8ccZUCUGDxOm4t8uT1qhMd0=";
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/gef
    cp gef.py $out/share/gef
    makeWrapper ${gdb}/bin/gdb $out/bin/gef \
      --add-flags "-q -x $out/share/gef/gef.py" \
      --set NIX_PYTHONPATH ${pythonPath} \
      --prefix PATH : ${
        lib.makeBinPath [
          python311
          bintools-unwrapped # for readelf
          file
          ps
          one_gadget
        ]
      }
  '';

  nativeCheckInputs = [
    gdb
    file
    ps
    git
    python311
    python311.pkgs.pytest
    python311.pkgs.pytest-xdist
    python311.pkgs.keystone-engine
    python311.pkgs.unicorn
    python311.pkgs.capstone
    python311.pkgs.ropper
    python311.pkgs.crccheck
    python311.pkgs.tqdm
    one_gadget
  ];
  checkPhase = ''
    # Skip some tests that require network access.
    sed -i '/def test_cmd_shellcode_get(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py
    sed -i '/def test_cmd_shellcode_search(self):/i \ \ \ \ @unittest.skip(reason="not available in sandbox")' tests/runtests.py

    # Patch the path to /bin/ls.
    sed -i 's+/bin/ls+${coreutils}/bin/ls+g' tests/runtests.py

    # Run the tests.
    make test
  '';

  meta = with lib; {
    description = "A modern experience for GDB with advanced debugging features for exploit developers & reverse engineers";
    homepage = "https://github.com/hugsy/gef";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ryzzen ];
  };
}
