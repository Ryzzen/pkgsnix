{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libusb
}:

rustPlatform.buildRustPackage rec {
  pname = "wchisp";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "ch32-rs";
    repo = "wchisp";
    rev = version;
    hash = "sha256-r3n8IlWLgnWtN7cbrT80lrg/+o8kRhXLL7jDxL20va4=";
  };

  cargoHash = "sha256-/zdD75+/WaKgB+FcGNWbg99NGr+7yqdrdxOxZ45PrhE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb
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
