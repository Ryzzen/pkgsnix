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
  runtimeShell,
}:
stdenv.mkDerivation rec {
  name = "binary-ninja-pro";
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
  src = ~/Overworld/Tools/binary-ninja/linux/binaryninja_commercial_linux.zip;

  icon = fetchurl {
    urls = [ "https://binary.ninja/icons/android-chrome-512x512.png" ];
    sha256 = "sha256-/f9RPsS7qrxqVhIzlNiIAVi0HKwGu/lV0DiGXsjBcFo=";
  };

  bninjaDesktopItem = makeDesktopItem {
    name = "binaryninja-jailed";
    exec = "binaryninja-jailed";
    icon = icon;
    comment = "Binary Ninja Disassembler without network access";
    desktopName = "Binary Ninja Jailed";
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
          $out/opt/binaryninja-wrapped \
          --prefix "QT_QPA_PLATFORM" ":" "wayland"

    command_path="$out/bin/binaryninja-jailed"
    cat << EOF > "$command_path"
    #! ${runtimeShell} -e
    exec /run/wrappers/bin/firejail --net=none "$out/opt/binaryninja-wrapped"
    EOF
    chmod 0755 "$command_path"


    install -d $out/share/applications
    cp $bninjaDesktopItem/share/applications/* $out/share/applications
  '';

  postFixup = ''
    patchelf --debug --add-needed libpython3.so \
      "$out/opt/binaryninja"
  '';
}
