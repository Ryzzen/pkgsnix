{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libusb
, udev
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "wlink";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "ch32-rs";
    repo = "wlink";
    rev = version;
    hash = "sha256-fKbtLGD6ch9S8WP2UhUBFisYko6BKK8v9HaHstUAKoE=";
  };

  cargoHash = "sha256-u1E+oAV7KM6xfYghjg/E1eQhSqF0PrcBvX7UQQGY6gM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb
    udev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.IOKit
  ];

  meta = with lib; {
    description = "An open source WCH-Link library/command line tool written in Rust";
    homepage = "https://github.com/ch32-rs/wlink";
    changelog = "https://github.com/ch32-rs/wlink/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
    mainProgram = "wlink";
  };
}
