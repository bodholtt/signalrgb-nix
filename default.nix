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
  tessdata = tesseract5.override { enableLanguages = [ "eng" ]; };
in
stdenv.mkDerivation {
  pname = "signalrgb";
  version = "2.5.82-7554";

  src = fetchurl {
    url = "https://pkgs.signalrgb.com/apt/pool/beta/main/s/signalrgb/signalrgb_2.5.82-7554_amd64.deb";
    hash = "sha256-nOc+jhzuVOewWDjdiXiBGMs/vmqrxIikmQEsiI9A+uo=";
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

    install -Dm644 etc/udev/rules.d/72-signalrgb.rules $out/lib/udev/rules.d/72-signalrgb.rules
    substituteInPlace $out/lib/udev/rules.d/72-signalrgb.rules \
      --replace-fail "/bin/chmod" "${coreutils}/bin/chmod"

    mkdir -p $out/opt $out/bin $out/share $out/lib/udev/rules.d
    cp -r opt/signalrgb $out/opt/
    cp -r usr/share/* $out/share/
    install -Dm644 etc/udev/rules.d/72-signalrgb.rules $out/lib/udev/rules.d/

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

    runHook postInstall
  '';

  # Start strict so you can see what's missing. Unused Qt platform plugins
  # (eglfs, linuxfb, vkkhrdisplay, vnc) will probably want libs like libinput
  # and mtdev. Once the real deps are satisfied, ignore only those.
  # autoPatchelfIgnoreMissingDeps = [ "libinput.so.10" "libmtdev.so.1" ];

  meta = {
    description = "SignalRGB (Linux beta)";
    homepage = "https://signalrgb.com/linux/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
