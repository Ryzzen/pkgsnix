{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  pname = "riscv-none-elf-gcc-xpack";
  version = "13.2.0-2";

  src = fetchzip {
    url = "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz";
    hash = "sha256-3hi7NCNurq9Wr4cSEFQJufJDEjwtgtm0U0pF+GvLyp4=";
  };

  installPhase = ''
    mkdir -p $out/bin
    for file in $src/bin/*; do
      base_name=$(basename $file)
      ln -s $file $out/bin/$base_name
	done
  '';

  meta = with lib; {
    description = "A binary distribution of the GNU RISC-V Embedded GCC toolchain";
    homepage = "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack";
    changelog = "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "riscv-none-elf-gcc-xpack";
    platforms = platforms.all;
  };
}
