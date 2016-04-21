{ pkgs }:

{
  allowUnfree = true;
  allowBroken = true;
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

    dockerEnv = callPackage ./docker.nix { };

    terraform = stdenv.mkDerivation {
      name = "terraform-0.6.14";
      src = fetchurl {
        url = "https://releases.hashicorp.com/terraform/0.6.14/terraform_0.6.14_darwin_amd64.zip";
        sha256 = "123pl4nlh6iqj2r3viax25zbs1xlfdgf22s3hg2v6p4xaidgad4k";
      };

      buildInputs = [ unzip ];

      buildCommand = ''
        mkdir -p $out/bin
        unzip $src -d $out/bin
      '';
    };

    nexus3 = stdenv.mkDerivation {
      name = "nexus-3.0.0-03";
      src = fetchurl {
        url = "http://download.sonatype.com/nexus/3/nexus-3.0.0-03-unix.tar.gz";
        sha256 = "1jnh6qcfdywp19yzawjzg41nsaaskbaj5kjwh8haa062zyg7crh6";
      };

      buildCommand = ''
        mkdir -p $out
        tar -xvzf $src --strip-components=1 -C $out
        substituteInPlace $out/bin/nexus.vmoptions \
            --replace "-Dkaraf.data=data" "-Dkaraf.data=/usr/local/var/nexus3" \
            --replace "-Djava.io.tmpdir=data/tmp" "-Djava.io.tmpdir=/usr/local/var/tmp/nexus3"
        substituteInPlace $out/etc/org.sonatype.nexus.cfg \
            --replace "application-port=8081" "application-port=18081"
      '';
    };
  };
}
