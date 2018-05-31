{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation {
  name = "container-environment";
  buildInputs = [
    (stdenv.mkDerivation {
      name = "docker-17.09.1-ce";
      src = fetchurl {
        url = "https://download.docker.com/mac/static/stable/x86_64/docker-17.09.1-ce.tgz";
        sha256 = "0qx79x9dj7nq0dvz8ms7fqh6fxz1pvsbjpblp776rx180qq6y4ip";
      };
      buildCommand = ''
        mkdir -p $out/bin
        tar -xvzf $src
        cp -fv docker/docker $out/bin
        chmod 755 $out/bin/docker
      '';
    })
    (stdenv.mkDerivation {
      name = "kubernetes-1.10.2";
      src = fetchurl {
        url = "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/darwin/amd64/kubectl";
        sha256 = "1bgj7qsy5dlkvg01iw7pik72fdcjji1v691nlqvb1ik3lixjhwv3";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp -fv $src $out/bin/kubectl
        chmod 755 $out/bin/kubectl
      '';
    })
    (stdenv.mkDerivation {
      name = "minikube-0.27.0";
      src = fetchurl {
        url = "https://storage.googleapis.com/minikube/releases/v0.25.0/minikube-darwin-amd64";
        sha256 = "1h8p8xysrpz6i1kg2gar40smp13bp76px1lmrgaylyixl2kgfdfk";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/minikube
        chmod 755 $out/bin/minikube
      '';
    })
  ];
}
