{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libusb1,
  udev,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "wlink";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "ch32-rs";
    repo = "wlink";
    rev = version;
    hash = "sha256-XxPvnIovShPvOhviLcVh2/+jwj27wS6WBHSeU6q8AIw=";
  };

  cargoHash = "sha256-AeqrTQ+38ffMINyt6YAstUL1ZDHENn3Lfv7hBOWyahU=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      libusb1
      udev
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.IOKit
    ];

  meta = with lib; {
    description = "An open source WCH-Link library/command line tool written in Rust";
    homepage = "https://github.com/ch32-rs/wlink";
    changelog = "https://github.com/ch32-rs/wlink/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [ ];
    mainProgram = "wlink";
  };
}
