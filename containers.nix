{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "container-environment";
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
    (stdenv.mkDerivation {
      name = "kubernetes-1.5.1";
      src = fetchurl {
        url = "https://storage.googleapis.com/kubernetes-release/release/v1.5.1/bin/darwin/amd64/kubectl";
        sha256 = "0hd1yvam3phyz9z5rmqqdv5vfv5wwjwmplydqqincb244nxqfi1m";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp -fv $src $out/bin/kubectl
        chmod 755 $out/bin/kubectl
      '';
    })
    (stdenv.mkDerivation {
      name = "minikube-0.14.0";
      src = fetchurl {
        url = "https://github.com/kubernetes/minikube/releases/download/v0.14.0/minikube-darwin-amd64";
        sha256 = "0a2zwfbddz3131923waxlks9j7wqbcra163ny8gc97cjw6hha24m";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/minikube
        chmod 755 $out/bin/minikube
      '';
    })
  ];
}
