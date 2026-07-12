{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "dae";
  version = "2.0.0";

  src = fetchurl {
    url = "https://github.com/daeuniverse/dae/releases/download/v${version}/dae-linux-x86_64_v3_avx2.tar.xz";
    sha256 = "c78f8296fea28a9597fb7396f35019929aca7cc20af8362b7e07074d14722ffb";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 usr/bin/dae $out/bin/dae
    runHook postInstall
  '';
  meta = with lib; {
    description = "eBPF-based Linux high-performance transparent proxy solution";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
