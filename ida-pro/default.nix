{ lib
, stdenv
, fetchurl
, libGL
, zlib
, libkrb5
, libsecret
, libunwind
, libxkbcommon
, glib
, makeWrapper
, openssl
, xorg
, dbus
, fontconfig
, freetype
, python311
, python311Packages
, unixtools
, hexdump
, makeDesktopItem
, runtimeShell
}:


stdenv.mkDerivation rec {
  pname = "ida-pro-jailed";
  version = "8.3.230608";

  src = /home/ryzzen/Overworld/Tools/IDA/8.3.230608_linux;
  passwd = /home/ryzzen/Overworld/Tools/IDA/idapass;
  replaceBinString = ./replace_bin_string.sh;

  icon = fetchurl {
    urls = [
      "https://www.hex-rays.com/products/ida/news/8_1/images/icon_pro.png"
      "https://web.archive.org/web/20221105181231if_/https://hex-rays.com/products/ida/news/8_1/images/icon_pro.png"
    ];
    sha256 = "sha256-Botgf/o3W1CBF4Zvr1Ae5X0ma7CCBRdp82/QQqzNfiY=";
  };

  ida64DesktopItem = makeDesktopItem {
    name = "ida";
    exec = "ida-jailed";
    icon = icon;
    comment = "Pro version of the world's smartest and most feature-full disassembler";
    desktopName = "IDA64 Jailed";
    genericName = "Interactive Disassembler";
    categories = [ "Development" ];
  };

  ldLibraryPath = lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
    glib
    xorg.libXi
    xorg.libxcb
    xorg.libXrender
    xorg.libXau
    xorg.libX11
    xorg.libSM
    xorg.libICE
    xorg.libXext
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    libkrb5
    libsecret
    libunwind
    libxkbcommon
    openssl
    dbus
    fontconfig
    freetype
    libGL
	python311
  ];

  nativeBuildInputs = [ makeWrapper python311 unixtools.xxd hexdump ];
  propagatedBuildInputs = [ python311 ];

  dontUnpack = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    IDADIR=$out/opt/${pname}
    PYLIB=$out/lib

    install -d $IDADIR $out/bin $out/share/applications

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) ${src}/idaprocl_hexarm64l_hexarml_hexmips64l_hexmipsl_hexppc64l_hexppcl_hexx64l_hexx86l_230608_04e576f7613b5ccc34ba7e88f250acf4.run \
      --mode unattended --prefix $IDADIR --installpassword "$(cat ${passwd})"

    rm $IDADIR/[Uu]ninstall*

    # Patching idapyswitch to get a usable python path
    mkdir -p $PYLIB
    for file in "${python311}/lib"/*.so*; do
      filename=$(basename "$file")
      ln -s "$file" "$PYLIB/$filename"
    done
    chmod +w $IDADIR/idapyswitch
    ${runtimeShell} ${replaceBinString} $IDADIR/idapyswitch "/usr/lib/x86_64-linux-gnu" "."

    # Applying dependencies
    for bb in ida64 assistant idapyswitch; do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $IDADIR/$bb
      wrapProgram \
        $IDADIR/$bb \
        --set LD_LIBRARY_PATH "$IDADIR:${ldLibraryPath}" \
        --set QT_PLUGIN_PATH "$IDADIR/plugins/platforms"
    done

    # Applying the new python lib
    cd $PYLIB
    echo '1' | $IDADIR/idapyswitch
    cd -

    command_path="$out/bin/ida-jailed"
    cat << EOF > "$command_path"
    #! ${runtimeShell} -e
    exec /run/wrappers/bin/firejail --net=none "$IDADIR/ida64"
    EOF
    chmod 0755 "$command_path"

    cp $ida64DesktopItem/share/applications/* $out/share/applications

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Freeware version of the world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "ida";
  };
}

