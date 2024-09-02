{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
, libkrb5
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-hound";
  version = "1.1.69";

  src = fetchFromGitHub {
    owner = "NH-RED-TEAM";
    repo = "RustHound";
    rev = "v${version}";
    hash = "sha256-PFDHs7Pgg3G+jrLQR8nkCGpQft/XoZLInJV55AjhrjQ=";
  };

  cargoHash = "sha256-NRfJWEWQ4g1fSwi5/coqhSTEzPbN3fOieZDOfY/q0sI=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
	libkrb5
  ];

  buildInputs = [
    openssl
	libkrb5
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  doCheck = false;

  meta = with lib; {
    description = "Active Directory data collector for BloodHound written in Rust";
    homepage = "https://github.com/NH-RED-TEAM/RustHound.git";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "rust-hound";
  };
}
