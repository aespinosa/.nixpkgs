{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "docker-environment";
  buildInputs = [
    (stdenv.mkDerivation {
      name = "docker-machine-0.7.0";
      src = fetchurl {
        url = "https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-Darwin-x86_64";
        sha256 = "1c42vyj9zz1qxfwmqj6nwf4bbcybghq53xb8dsr862cy4h2xd3v0";
      };
      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/docker-machine
        chmod 755 $out/bin/docker-machine
      '';
    })
    (stdenv.mkDerivation {
      name = "docker-1.10.3";
      src = fetchurl {
        url = "https://get.docker.com/builds/Darwin/x86_64/docker-1.10.3";
        sha256 = "0kh5k1rf7vnj0h98fkk91lirmr8wd4ribl8b1i08jsc173c30hq5";
      };
      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/docker
        chmod 755 $out/bin/docker
      '';
    })
    (stdenv.mkDerivation {
      name = "docker-compose-1.6.2";
      src = fetchurl {
        url = "https://github.com/docker/compose/releases/download/1.6.2/docker-compose-Darwin-x86_64";
        sha256 = "0724glrnc2jni57kgxs5ha13mqnq7fvlyp0a226sn6sqd6fh5b5s";
      };
      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/docker-compose
        chmod 755 $out/bin/docker-compose
      '';
    })
  ];
}
