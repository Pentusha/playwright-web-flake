{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  versions,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";
  inherit (versions.obscura) version;

  srcs = {
    x86_64-linux = fetchzip {
      url = "https://github.com/h4ckf0r0day/obscura/releases/download/v${version}/obscura-x86_64-linux.tar.gz";
      hash = versions.obscura.hashes."x86_64-linux";
      stripRoot = false;
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/h4ckf0r0day/obscura/releases/download/v${version}/obscura-aarch64-linux.tar.gz";
      hash = versions.obscura.hashes."aarch64-linux";
      stripRoot = false;
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/h4ckf0r0day/obscura/releases/download/v${version}/obscura-x86_64-macos.tar.gz";
      hash = versions.obscura.hashes."x86_64-darwin";
      stripRoot = false;
    };
    aarch64-darwin = fetchzip {
      url = "https://github.com/h4ckf0r0day/obscura/releases/download/v${version}/obscura-aarch64-macos.tar.gz";
      hash = versions.obscura.hashes."aarch64-darwin";
      stripRoot = false;
    };
  };
in
stdenv.mkDerivation {
  pname = "obscura";
  inherit version;
  src = srcs.${system} or throwSystem;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp obscura* $out/bin/
  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/obscura \
      --set-default SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
  '';

  meta = {
    description = "An open-source headless browser engine for AI agents and web scraping";
    homepage = "https://github.com/h4ckf0r0day/obscura";
    license = lib.licenses.asl20;
    mainProgram = "obscura";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
