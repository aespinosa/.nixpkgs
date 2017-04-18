{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation {
  name = "container-environment";
  buildInputs = [
    (stdenv.mkDerivation{
      name = "habitat-0.19.0";
      buildInputs = [ unzip ];
      src = fetchurl {
        url = "https://dl.bintray.com/habitat/stable/darwin/x86_64/hab-0.19.0-20170311030920-x86_64-darwin.zip";
        sha256 = "0n0p5r3minj2j2yiklkqs084x1q5s4dywf6dcvbb8gsjzj1nzy41";
      };

      buildCommand = ''
        unzip $src
        mkdir -p $out/bin
        cp hab-0.19.0-20170311030920-x86_64-darwin/hab $out/bin/hab
        chmod 755 $out/bin/hab
      '';
    })
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
    (stdenv.mkDerivation {
      name = "kubernetes-1.6.1";
      src = fetchurl {
        url = "https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/darwin/amd64/kubectl";
        sha256 = "0ipkdjjzz3j6g66x111wv0jrcnj0vpmd4z1lcqcjkw4g8bpdl583";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp -fv $src $out/bin/kubectl
        chmod 755 $out/bin/kubectl
      '';
    })
    (stdenv.mkDerivation {
      name = "minikube-0.17.1";
      src = fetchurl {
        url = "https://storage.googleapis.com/minikube/releases/v0.18.0/minikube-darwin-amd64";
        sha256 = "1svdcrbbrw92xjkz4xfydqzqk05sb0ys1lwvfs0cxyncgksca79h";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/minikube
        chmod 755 $out/bin/minikube
      '';
    })
  ];
}
