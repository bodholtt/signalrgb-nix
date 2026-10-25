{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  atk,
  brotli,
  bzip2,
  cairo,
  curl,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  krb5,
  libdrm,
  libglvnd,
  libpulseaudio,
  libsecret,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  pipewire,
  systemd,
  vulkan-loader,
  wayland,
  zlib,
  zstd,
  tesseract5,
  libX11,
  libxcb,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXtst,
  libxkbfile,
  libxshmfence,
  xcbutil,
  xcbutilcursor,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
  coreutils,
}:

let
  version = "2.5.83-7568";
  tessdata = tesseract5.override { enableLanguages = [ "eng" ]; };
in
stdenv.mkDerivation {
  pname = "signalrgb";
  inherit version;

  src = fetchurl {
    url = "https://pkgs.signalrgb.com/apt/pool/beta/main/s/signalrgb/signalrgb_${version}_amd64.deb";
    hash = "sha256-tZ65KCyTdhLXaXTec/7S5NRZAd78KkoO+hUH7tJW6T8=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    atk
    brotli
    bzip2
    cairo
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    krb5
    libdrm
    libglvnd
    libpulseaudio
    libsecret
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    systemd
    vulkan-loader
    wayland
    zlib
    zstd
    tessdata
    stdenv.cc.cc.lib
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libXtst
    libxkbfile
    libxshmfence
    xcbutil
    xcbutilcursor
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/share
    cp -r opt/signalrgb $out/opt/
    cp -r usr/share/* $out/share/

    install -Dm644 etc/udev/rules.d/72-signalrgb.rules $out/lib/udev/rules.d/72-signalrgb.rules
    substituteInPlace $out/lib/udev/rules.d/72-signalrgb.rules \
      --replace-fail "/bin/chmod" "${coreutils}/bin/chmod"

    makeWrapper $out/opt/signalrgb/SignalRgb $out/bin/signalrgb \
      --set QT_PLUGIN_PATH  $out/opt/signalrgb/plugins \
      --set QML2_IMPORT_PATH $out/opt/signalrgb/qml \
      --set TESSDATA_PREFIX ${tessdata}/share/tessdata \
      --prefix LD_LIBRARY_PATH : $out/opt/signalrgb/lib:${
        lib.makeLibraryPath [
          vulkan-loader
          libglvnd
        ]
      }

    # fix the .desktop file's Exec/Icon paths
    substituteInPlace $out/share/applications/signalrgb.desktop \
      --replace-quiet "/usr/bin/signalrgb" "$out/bin/signalrgb"

    # register as handler for signalrgb://
    sed -i '/^Exec=/a MimeType=x-scheme-handler/signalrgb;' \
      $out/share/applications/signalrgb.desktop

    runHook postInstall
  '';

  meta = {
    description = "SignalRGB (Linux beta)";
    homepage = "https://signalrgb.com/linux/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "signalrgb";
  };
}
