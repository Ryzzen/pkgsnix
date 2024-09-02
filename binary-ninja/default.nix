{
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  fetchurl,
  unzip,
  libGL,
  wayland,
  qt6,
  wrapQtAppsHook,
  python310,
  glib,
  fontconfig,
  dbus,
}:
stdenv.mkDerivation rec {
  name = "binary-ninja";
  buildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    wayland
    libGL
    qt6.full
    qt6.qtbase
    python310
    stdenv.cc.cc.lib
    glib
    fontconfig
    dbus
  ];
  src = ~/Overworld/Tools/binary-ninja/binaryninja_free_linux.zip;

  icon = fetchurl {
    urls = [ "https://binary.ninja/icons/android-chrome-512x512.png" ];
    sha256 = "sha256-/f9RPsS7qrxqVhIzlNiIAVi0HKwGu/lV0DiGXsjBcFo=";
  };

  bninjaDesktopItem = makeDesktopItem {
    name = "binary-ninja";
    exec = "binaryninja";
    icon = icon;
    comment = "Binary Ninja Disassembler";
    desktopName = "Binary Ninja";
    genericName = "Interactive Disassembler";
    categories = [ "Development" ];
  };

  nativeBuildInputs = [
    wrapQtAppsHook
    python310.pkgs.wrapPython
  ];

  dontWrapQtApps = true;
  buildPhase = ":";
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
          $out/bin/binaryninja \
          --prefix "QT_QPA_PLATFORM" ":" "wayland"
    install -d $out/share/applications
    cp $bninjaDesktopItem/share/applications/* $out/share/applications
  '';

  postFixup = ''
    patchelf --debug --add-needed libpython3.so \
      "$out/opt/binaryninja"
  '';
}
