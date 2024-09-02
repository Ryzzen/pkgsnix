{ lib
, fetchurl
, appimageTools
}:

let
  pname = "nrfconnect";
  version = "5.0.0";

  src = fetchurl {
    url = "https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-connect-for-desktop/5-0-0/nrfconnect-5.0.0-x86_64.appimage";
    hash = "sha256-WVPe0bZcOBqV38NYN/DRo6vUjkwaN3QonJK1S+47/iw=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.segger-jlink ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/nrfconnect.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/nrfconnect.png \
      -t $out/share/icons/hicolor/512x512/apps
    substituteInPlace $out/share/applications/nrfconnect.desktop \
      --replace 'Exec=AppRun' 'Exec=nrfconnect'
  '';

  meta = with lib; {
    description = "Nordic Semiconductor nRF Connect for Desktop";
    homepage = "https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-desktop";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ stargate01 ];
    mainProgram = "nrfconnect";
  };
}
