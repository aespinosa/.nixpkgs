{ stdenv, fetchurl, awscli, makeWrapper }:

let
  deisCtl = stdenv.mkDerivation {
    name = "deisctl-1.12.3";
    buildInputs = [ makeWrapper ];
    src = fetchurl {
      url = "https://github.com/deis/deis/releases/download/v1.12.3/deisctl-1.12.3-darwin-amd64.run";
      sha256 = "0cia0w60d6xwjnsfij8nh4dq3jwzgyvl9mia4qcinv0h9axb53f3";
    };

    phases = [ "unpackPhase" "installPhase" ];

    unpackPhase = ''
      bash $src --noexec
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/libexec
      cp deisctl $out/libexec/deisctl
      mkdir -p $out/lib/deis/units
      makeWrapper $out/libexec/deisctl $out/bin/deisctl --set DEISCTL_TUNNEL $out/lib/deis/units

      $out/bin/deisctl refresh-units -p $out/lib/deis/units 
    '';
  }; in

stdenv.mkDerivation {
  name = "deisEnvironment";
  buildInputs = [ awscli deisCtl ];
}
