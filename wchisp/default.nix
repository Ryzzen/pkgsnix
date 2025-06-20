{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libusb1,
}:

rustPlatform.buildRustPackage rec {
  pname = "wchisp";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "ch32-rs";
    repo = "wchisp";
    rev = version;
    hash = "sha256-IId80M1fHF6WVgcL8i7CPer5KBhukBkPa8jYCBqSQeY=";
  };

  cargoHash = "sha256-aPRaABa7WDy1vjwTpT9Y0t5oofBHmHip0ycv6cBtgpU=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
  ];

  meta = with lib; {
    description = "WCH ISP Tool in Rust";
    homepage = "https://github.com/ch32-rs/wchisp";
    changelog = "https://github.com/ch32-rs/wchisp/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "wchisp";
  };
}
