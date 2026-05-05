{
  lib,
  stdenv,
  autoPatchelfHook,
  unzip,
  openjdk,
  buildFHSEnv,
  libusb1,
  glib,
  libz,
  libkrb5,
  openssl,
  xorg,
  icoutils,
  qt6Packages,
  gtk3,
  pcsclite,
  wrapGAppsHook3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  patchelf,
}:

let
  pname = "stm32cubeprog";
  version = "2.22.0";

  jdk = openjdk.override (
    lib.optionalAttrs stdenv.hostPlatform.isLinux {
      enableJavaFX = true;
    }
  );
in
stdenv.mkDerivation {
  inherit pname version;

  src = builtins.path {
    path = /home/ryzzen/Tools/Stm32CubeProgrammer/SetupSTM32CubeProgrammer_linux_64.zip;
    name = "SetupSTM32CubeProgrammer_linux_64.zip";
  };

  nativeBuildInputs = [
    jdk
    unzip
    patchelf
    qt6Packages.wrapQtAppsHook
    wrapGAppsHook3
    copyDesktopItems
    autoPatchelfHook
    icoutils
  ];

  buildInputs = [
    jdk
    libusb1
    glib
    libz
    libkrb5
    openssl
    pcsclite
    xorg.libX11
    qt6Packages.qtbase
    qt6Packages.qtserialport
    qt6Packages.qtwayland
    gtk3
  ];

  unpackCmd = ''
    mkdir -p stm32cubeprg
    unzip -d stm32cubeprg $curSrc SetupSTM32CubeProgrammer-${version}.exe
    mkdir -p stm32cubeprg/jre/bin
    touch stm32cubeprg/jre/bin/java
  '';

  installPhase =
    let
      installEnv = buildFHSEnv {
        name = "installer-env";
        targetPkgs = pkgs: with pkgs; [ jdk ];
        runScript = "java";
      };
    in
    ''
      runHook preInstall

      ${installEnv}/bin/${installEnv.name} \
        -jar \
        -DINSTALL_PATH=stm32cubeprg \
        SetupSTM32CubeProgrammer-${version}.exe \
        -options-system

      rm -rf stm32cubeprg/bin/jre

      mkdir -p $out
      mv ./stm32cubeprg/* $out
      chmod -R u+w $out

      # Avoid collisions in home-manager-path while keeping ST's bundled Qt libs available.
      mkdir -p $out/opt/stm32cubeprog-libs
      mv $out/lib/libQt6*.so* $out/opt/stm32cubeprog-libs/ 2>/dev/null || true
      mv $out/lib/libQt5*.so* $out/opt/stm32cubeprog-libs/ 2>/dev/null || true

      mkdir newjar
      cd newjar
      jar -xf $out/bin/STM32CubeProgrammerLauncher
      jar -cfm $out/bin/STM32CubeProgrammerLauncher META-INF/MANIFEST.MF .
      cd ..

      mkdir icons
      icotool -x $out/util/Programmer.ico -o icons/
      cd icons
      ls | awk -v prefix=$out/share/icons/hicolor/ -F'[_x.]' \
        '{ dest=prefix $3 "x" $4; print "mkdir -p " dest "/apps/ && mv " $0 " " dest "/apps/" "${pname}" "." $NF}' \
        | bash
      cd ..

      mkdir -p $out/lib/udev/rules.d/
      mv $out/Drivers/rules/* $out/lib/udev/rules.d/

      autoPatchelf $out/bin/STM32_Programmer_CLI
      autoPatchelf $out/bin/STM32_SigningTool_CLI
      autoPatchelf $out/bin/STM32_KeyGen_CLI

      patchelf --set-rpath "$out/lib:$out/opt/stm32cubeprog-libs:${lib.makeLibraryPath buildInputs}" $out/bin/STM32_Programmer_CLI
      patchelf --set-rpath "$out/lib:$out/opt/stm32cubeprog-libs:${lib.makeLibraryPath buildInputs}" $out/bin/STM32_SigningTool_CLI
      patchelf --set-rpath "$out/lib:$out/opt/stm32cubeprog-libs:${lib.makeLibraryPath buildInputs}" $out/bin/STM32_KeyGen_CLI

      makeWrapper ${installEnv}/bin/${installEnv.name} $out/bin/${pname} \
        --add-flags "-jar $out/bin/STM32CubeProgrammerLauncher"

      runHook postInstall
    '';

  autoPatchelfIgnoreMissingDeps = [
    "libSTLinkUSBDriver.so"
    "libhsmp11.so"
    "libcrypto.so.1.0.0"
    "libQt5Core.so.5"
    "libQt6WaylandEglClientHwIntegration.so.6"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      icon = pname;
      desktopName = "STM32CubeProgrammer";
      comment = "All-in-one multi-OS software tool for programming STM32 products";
      exec = pname;
      categories = [ "Development" ];
    })
  ];

  meta = with lib; {
    description = "All-in-one multi-OS software tool for programming STM32 products";
    longDescription = ''
      STM32CubeProgrammer (STM32CubeProg) is an all-in-one multi-OS
      software tool for programming STM32 products.
      It provides an easy-to-use and efficient environment for reading,
      writing, and verifying device memory through both the debug interface
      (JTAG and SWD) and the bootloader interface.
    '';
    homepage = "https://www.st.com/en/development-tools/stm32cubeprog.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
