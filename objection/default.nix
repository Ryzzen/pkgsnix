{
  lib,
  python3,
  fetchFromGitHub,
  click,
  delegator-py,
  flask,
  frida-tools,
  litecli,
  prompt-toolkit,
  pygments,
  requests,
  semver,
  tabulate,
  aapt,
  apksigner,
  androidenv,
}:

let
  buildToolsVersion = "33.0.2";
  androidComposition = androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion ];
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "objection";
  version = "1.11.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "sensepost";
    repo = "objection";
    rev = version;
    hash = "sha256-UXzQP34g0CzFHwJ6dVsKC8vUbUQnGwPA3Os6Oj1Rfp4=";
  };

  zipAlignPath = "${androidComposition.androidsdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/zipalign";

  propagatedBuildInputs = with python3.pkgs; [
    setuptools
    click
    delegator-py
    flask
    frida-tools
    litecli
    prompt-toolkit
    pygments
    requests
    semver
    tabulate
    aapt
    apksigner
  ];

  postInstall = ''
    ln -sf ${aapt}/bin/aapt2 $out/bin/aapt
    ln -sf ${zipAlignPath} $out/bin/zipalign
  '';

  pythonImportsCheck = [ "objection" ];

  meta = with lib; {
    description = "Objection - runtime mobile exploration";
    homepage = "https://github.com/sensepost/objection";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
