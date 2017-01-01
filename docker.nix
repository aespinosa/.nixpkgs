{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "docker-environment";
  buildInputs = [
    (stdenv.mkDerivation {
      name = "docker-1.11.0";
      src = fetchurl {
        url = "https://get.docker.com/builds/Darwin/x86_64/docker-1.11.0.tgz";
        sha256 = "0wsgzjlbqhd9sq4wmvmxb5084l03fms8cijs1srbw5rfgvrzbr15";
      };
      buildCommand = ''
        mkdir -p $out/bin
        tar -xvzf $src --strip-components=1 -C $out/bin
      '';
    })
  ];
}
