{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation {
  name = "container-environment";
  buildInputs = [
    (stdenv.mkDerivation {
      name = "docker-17.05-ce-rc1";
      src = fetchurl {
        url = "https://test.docker.com/builds/Darwin/x86_64/docker-17.05.0-ce-rc1.tgz";
        sha256 = "1z8d9vfjgwhgmdi57r64zkw0i59mgvh4lgg07pb821qljgd78dnl";
      };
      buildCommand = ''
        mkdir -p $out/bin
        tar -xvzf $src
        cp -fv docker/docker $out/bin
        chmod 755 $out/bin/docker
      '';
    })
    (stdenv.mkDerivation {
      name = "kubernetes-1.7.0";
      src = fetchurl {
        url = "https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/darwin/amd64/kubectl";
        sha256 = "0fvklj192ihim7hw99yznhfiyaa0ydgh6s2a625hds6v223apb9v";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp -fv $src $out/bin/kubectl
        chmod 755 $out/bin/kubectl
      '';
    })
    (stdenv.mkDerivation {
      name = "minikube-0.20.0";
      src = fetchurl {
        url = "https://storage.googleapis.com/minikube/releases/v0.20.0/minikube-darwin-amd64";
        sha256 = "06bs7dw53yhh351y1qirdkjw45n4ad1p3grlyq0vypbl52vkf5sr";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp $src $out/bin/minikube
        chmod 755 $out/bin/minikube
      '';
    })
  ];
}
