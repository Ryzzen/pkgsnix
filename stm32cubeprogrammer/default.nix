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

  runtimeLibs = [
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
    makeWrapper
  ];

  buildInputs = runtimeLibs;

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

      mkdir -p $out/opt/${pname}
      mv ./stm32cubeprg/* $out/opt/${pname}
      chmod -R u+w $out/opt/${pname}

      mkdir -p $out/bin

      autoPatchelf $out/opt/${pname}/bin/STM32_Programmer_CLI
      autoPatchelf $out/opt/${pname}/bin/STM32_SigningTool_CLI
      autoPatchelf $out/opt/${pname}/bin/STM32_KeyGen_CLI

      patchelf --set-rpath "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}" $out/opt/${pname}/bin/STM32_Programmer_CLI
      patchelf --set-rpath "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}" $out/opt/${pname}/bin/STM32_SigningTool_CLI
      patchelf --set-rpath "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}" $out/opt/${pname}/bin/STM32_KeyGen_CLI

      makeWrapper $out/opt/${pname}/bin/STM32_Programmer_CLI $out/bin/STM32_Programmer_CLI \
        --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}"

      makeWrapper $out/opt/${pname}/bin/STM32_SigningTool_CLI $out/bin/STM32_SigningTool_CLI \
        --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}"

      makeWrapper $out/opt/${pname}/bin/STM32_KeyGen_CLI $out/bin/STM32_KeyGen_CLI \
        --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}"

      mkdir newjar
      cd newjar
      jar -xf $out/opt/${pname}/bin/STM32CubeProgrammerLauncher
      jar -cfm $out/opt/${pname}/bin/STM32CubeProgrammerLauncher META-INF/MANIFEST.MF .
      cd ..

      makeWrapper ${installEnv}/bin/${installEnv.name} $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "$out/opt/${pname}/lib:${lib.makeLibraryPath runtimeLibs}" \
        --add-flags "-jar $out/opt/${pname}/bin/STM32CubeProgrammerLauncher"

      mkdir -p $out/share/icons/hicolor
      mkdir icons
      icotool -x $out/opt/${pname}/util/Programmer.ico -o icons/
      cd icons
      ls | awk -v prefix=$out/share/icons/hicolor/ -F'[_x.]' \
        '{ dest=prefix $3 "x" $4; print "mkdir -p " dest "/apps/ && mv " $0 " " dest "/apps/" "${pname}" "." $NF}' \
        | bash
      cd ..

      mkdir -p $out/lib/udev/rules.d/
      mv $out/opt/${pname}/Drivers/rules/* $out/lib/udev/rules.d/

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
      comment = "STM32 programming tool";
      exec = pname;
      categories = [ "Development" ];
    })
  ];

  meta = with lib; {
    description = "STM32CubeProgrammer";
    homepage = "https://www.st.com/en/development-tools/stm32cubeprog.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
