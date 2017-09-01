{ pkgs }:

{
  allowUnfree = true;
  allowBroken = true;
  packageOverrides = pkgs: with pkgs; rec {
    workstationEnv = buildEnv {
      name = "workstation-environment";
      paths = [ screen gitMinimal git-lfs tig ack zsh irssi ];
    };

    vmwareFusion = stdenv.mkDerivation {
      name = "vmware-fusion";
      buildCommand = ''
        mkdir -p $out/bin
        ln -sf /Applications/VMware\ Fusion.app/Contents/Library/vmrun \
           $out/bin/vmrun
        ln -sf /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli \
           $out/bin/vmnet-cli
      '';
    };

    macvim = stdenv.mkDerivation {
      name = "macvim-134";
      src = fetchurl {
        url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-134/MacVim.dmg";
        sha256 = "140rchlq2zgz21bwrpnm04ylm4q3p64ikzpdhj1bhqxbnfw482np";
      };
      buildInputs = [ p7zip ];
      buildCommand = ''
        7z x $src
        cd MacVim
        mkdir -p $out/Applications
        cp -rfv MacVim.app $out/Applications

        chmod 755 $out/Applications/MacVim.app/Contents/MacOS/* \
                  $out/Applications/MacVim.app/Contents/bin/*
        mkdir -p $out/bin
        ln -sf $out/Applications/MacVim.app/Contents/bin/mvim $out/bin/mvim
        ln -sf $out/bin/mvim $out/bin/vim
        ln -sf $out/bin/mvim $out/bin/vi
        ln -sf $out/bin/mvim $out/bin/gvim
      '';
    };

    rubyEnv = stdenv.mkDerivation {
      name = "rubyEnv";
      buildInputs = [ ruby libiconv libxml2 libxslt ];
      shellHook = ''
        export GEM_HOME=$out
        export PATH=$GEM_HOME/bin:$PATH
      '';
    };

    chefEnv =  callPackage ./chef.nix { ruby = ruby_2_4; };

    plistService = callPackage ./plist.nix {};

    jenkinsService = callPackage ./jenkins.nix {};

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
      name = "nexus-3.5.1-02";
      src = fetchurl {
        url = "http://download.sonatype.com/nexus/3/nexus-3.5.1-02-unix.tar.gz";
        sha256 = "10hk4ll5s4kmyb0y9bznxi0arzwv52f3r84j44bdrx5mkfjjvbc2";
      };

      buildCommand = ''
        mkdir -p $out
        tar -xvzf $src --strip-components=1 -C $out
        substituteInPlace $out/bin/nexus.vmoptions \
            --replace "-Dkaraf.data=../sonatype-work/nexus3" "-Dkaraf.data=/usr/local/var/nexus3" \
            --replace "-Djava.io.tmpdir=../sonatype-work/nexus3/tmp" "-Djava.io.tmpdir=/usr/local/var/tmp/nexus3" \
            --replace "-XX:LogFile=../sonatype-work/nexus3/log/jvm.log" "-XX:LogFile=/usr/local/var/nexus3/log/jvm.log"

        substituteInPlace $out/bin/nexus \
            --replace "# INSTALL4J_JAVA_HOME_OVERRIDE=" "app_java_home=\"/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home\""
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
  };
}
