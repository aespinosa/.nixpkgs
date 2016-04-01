{ pkgs }:

{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {
    workstationEnv = buildEnv {
      name = "workstation-environment";
      paths = [ screen gitMinimal tig ack zsh irssi macvim ];
    };

    rubyEnv = stdenv.mkDerivation {
      name = "rubyEnv";
      buildInputs = [
        ruby libiconv libxml2 libxslt
        darwin.apple_sdk.frameworks.CoreServices darwin.libobjc
      ];
      shellHook = ''
        export GEM_HOME=$out
        export PATH=$GEM_HOME/bin:$PATH
      '';
    };

    chefEnv = stdenv.mkDerivation {
      name = "chefEnv";
      buildInputs = [ ruby_2_1 darwin.apple_sdk.frameworks.CoreServices
                      darwin.libobjc];
      shellHook = ''
        export GEM_HOME=$out
        export PATH=$GEM_HOME/bin:$PATH
      '';
    };

    plistService = callPackage ./plist.nix {};

    jenkinsService = callPackage ./jenkins.nix {};
    aptCacherService = plistService {
      name = "apt-cacher-ng";
      programArgs = [
        "${apt-cacher-ng}/sbin/apt-cacher-ng" "-c"
        "/usr/local/etc/apt-cacher-ng"
        "foreground=1"
      ];
    };
    dnsmasqService = plistService {
      name = "dnsmasq";
      programArgs = [
        "${dnsmasq}/bin/dnsmasq" "--keep-in-foreground"
        "-C" "/usr/local/etc/dnsmasq.conf"
      ];
    };

    nexusService = plistService {
      name = "nexus";
      workingDirectory = nexus.out;
      programArgs = [
        "java"
        "-Dnexus-work=/usr/local/var/nexus"
        "-Dnexus-webapp-context-path=/"
        "-cp" "${nexus}/conf/:${nexus}/lib/*"
        "org.sonatype.nexus.bootstrap.Launcher"
        "${nexus}/conf/jetty.xml"
        "${nexus}/conf/jetty-requestlog.xml"
      ];
    };

    shoutService = plistService {
      name = "shout";
      programArgs = [
        "${shout}/bin/shout" "--private" "start"
      ];
    };

    deisEnv = callPackage ./deis.nix { inherit (pythonPackages) pyyaml; };


    ecsCli = stdenv.mkDerivation {
      name = "ecs-cli-0.2.1";
      src = fetchurl {
        url = "https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-darwin-amd64-v0.2.1";
        sha256 = "12yrqan7ilxsxplmmbii7n2vpzwa0c6phfhbw0rl6xgn3zmisxhf";
      };

      buildCommand = ''
        mkdir -p $out/bin
        cp -v $src $out/bin/ecs-cli
        chmod 755 $out/bin/ecs-cli
      '';
    };

    dockerEnv = stdenv.mkDerivation {
      name = "docker-environment";
      buildInputs = [
        (stdenv.mkDerivation {
          name = "docker-machine-0.6.0";
          src = fetchurl {
            url = "https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-Darwin-x86_64";
            sha256 = "1dxs2s1hyyvrkf7kxwvpzamyqnqs6p5phm2v5p5gsfxf69jmkkwn";
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
    };
  };
}
