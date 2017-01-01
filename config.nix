{ pkgs }:

{
  allowUnfree = true;
  allowBroken = true;
  packageOverrides = pkgs: with pkgs; rec {
    workstationEnv = buildEnv {
      name = "workstation-environment";
      paths = [ screen gitMinimal git-lfs tig ack zsh irssi ];
    };

    macvim = stdenv.mkDerivation {
      name = "macvim-122";
      src = fetchurl {
        url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-112/MacVim.dmg";
        sha256 = "17xhkfnb6m8im7pad88a2ynz5gkdfwy58dq7wnbmp2rdn66m9i5v";
      };
      buildInputs = [ p7zip ];
      buildCommand = ''
        7z x $src
        cd MacVim
        ls
        mkdir -p $out/bin
        cp -fv mvim $out/bin
        mkdir -p $out/Applications
        cp -rfv MacVim.app $out/Applications

        chmod 755 $out/bin/mvim $out/Applications/MacVim.app/Contents/MacOS/*
        ln -sf $out/bin/mvim $out/bin/vim
        ln -sf $out/bin/mvim $out/bin/vi
        ln -sf $out/bin/mvim $out/bin/gvim
      '';
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
      buildInputs = [
        ruby_2_1 libiconv libxml2 libxslt
        darwin.apple_sdk.frameworks.CoreServices darwin.libobjc];
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
      programArgs = [
        "${nexus}/bin/nexus"
        "run"
      ];
    };

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

    containerEnv = callPackage ./containers.nix { };

    terraform = stdenv.mkDerivation {
      name = "terraform-0.7.0";
      src = fetchurl {
        url = "https://releases.hashicorp.com/terraform/0.7.0/terraform_0.7.0_darwin_amd64.zip";
        sha256 = "013byzhgh4bc9kiy52fb77z45v876wvgys0zg0yhsfwbhyrf8827";
      };

      buildInputs = [ unzip ];

      buildCommand = ''
        mkdir -p $out/bin
        unzip $src -d $out/bin
      '';
    };

    nexus = stdenv.mkDerivation {
      name = "nexus-3.1.0-04";
      src = fetchurl {
        url = "http://download.sonatype.com/nexus/3/nexus-3.1.0-04-unix.tar.gz";
        sha256 = "02pwqrhg4dwbvv801fjlk3rw4xwfypf2728gylsnq2q1ppfdc75z";
      };

      buildCommand = ''
        mkdir -p $out
        tar -xvzf $src --strip-components=1 -C $out
        substituteInPlace $out/bin/nexus.vmoptions \
            --replace "-Dkaraf.data=../sonatype-work/nexus3" "-Dkaraf.data=/usr/local/var/nexus3" \
            --replace "-Djava.io.tmpdir=../sonatype-work/nexus3/tmp" "-Djava.io.tmpdir=/usr/local/var/tmp/nexus3" \
            --replace "-XX:LogFile=../sonatype-work/nexus3/log/jvm.log" "-XX:LogFile=/usr/local/var/nexus3/log/jvm.log"
      '';
    };

    google-cloud-sdk = stdenv.mkDerivation {
      name = "google-cloud-sdk-110.0.0";
      src = fetchurl {
        url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-117.0.0-darwin-x86_64.tar.gz";
        sha1 = "be176b412a861ba1d7399088f6c77c513d3dfb13";
      };

      buildCommand = ''
        tar -xzf $src --strip-components=1
        mkdir -p $out
        cp -rfv bin $out/bin
        cp -rfv lib $out/lib
      '';
    };

    packer = stdenv.mkDerivation {
      name = "packer-0.12.0";
      src = fetchurl {
        url =  "https://releases.hashicorp.com/packer/0.12.0/packer_0.12.0_darwin_amd64.zip";
        sha256 = "e3f25ad619f35e10a4195c971d78f29abceb16877bbf2bd75182140373d02bd3";
      };

      buildInputs = [ unzip ];

      buildCommand = ''
        mkdir -p $out/bin
        cd $out/bin
        unzip $src
      '';
    };

  };
}
