{ lib, stdenv, fetchurl, unzip, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "dae";
  version = "2.0.0";
  src = fetchurl {
    url = "https://github.com/daeuniverse/dae/releases/download/v${version}/dae-linux-x86_64_v3_avx2.zip";
    sha256 = "3f6ece3edd3f452fb9974a3ca70692f5b52a23ee42b83477e01dd9aed43a2bf7";
  };
  nativeBuildInputs = [ unzip autoPatchelfHook ];
  sourceRoot = ".";
  unpackCmd = "unzip $curSrc";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 dae-linux-x86_64_v3_avx2 $out/bin/dae
    runHook postInstall
  '';
  meta = with lib; {
    description = "eBPF-based Linux high-performance transparent proxy solution";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
