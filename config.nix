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
      name = "macvim-147";
      src = fetchurl {
        url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-147/MacVim.dmg";
        sha256 = "07szhx043ixym8n15n5xn9g5mjf1r8zi28hgdbpyf07vrfymc0zg";
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
      name = "terraform-0.11.5";
      src = fetchurl {
        url = "https://releases.hashicorp.com/terraform/0.11.5/terraform_0.11.5_darwin_amd64.zip";
        sha256 = "11imz4m3x1swr3fgglalll9wab5kmfvxc5qbri29a90skfpqpxqa";
      };

      buildInputs = [ unzip ];

      buildCommand = ''
        mkdir -p $out/bin
        unzip $src -d $out/bin
      '';
    };

    nexus = stdenv.mkDerivation {
      name = "nexus-3.9.0-01";
      src = fetchurl {
        url = "http://download.sonatype.com/nexus/3/nexus-3.9.0-01-unix.tar.gz";
        sha256 = "1b14iyh1va8lyzsfv46azrwbxcs0mjhw560bn4r21im4pmas92cr";
      };

      buildCommand = ''
        mkdir -p $out
        tar -xvzf $src --strip-components=1 -C $out
        substituteInPlace $out/bin/nexus.vmoptions \
            --replace "-Dkaraf.data=../sonatype-work/nexus3" "-Dkaraf.data=/usr/local/var/nexus3" \
            --replace "-Djava.io.tmpdir=../sonatype-work/nexus3/tmp" "-Djava.io.tmpdir=/usr/local/var/tmp/nexus3" \
            --replace "-XX:LogFile=../sonatype-work/nexus3/log/jvm.log" "-XX:LogFile=/usr/local/var/nexus3/log/jvm.log"

        substituteInPlace $out/bin/nexus \
            --replace "# INSTALL4J_JAVA_HOME_OVERRIDE=" "app_java_home=\"${jre8_headless}\""
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

    # macOS installation
    # nix-env -iA nixpkgs.chefdk -p /opt/chefdk
    # Install just the "binaries"
    # nix-env -iA nixpkgs.chefdk.bin 
    #
    # Linux (NixOS)
    # nix-env -iA nixpkgs.chefdk -p /opt/chefdk
    # Create a chroot environment
    # (pkgs.buildFHSUserEnv {
    #   name = "chefdk";
    #   runScript = "bash";
    #   targetPkgs = pkgs: [ pkgs.chefdk.bin ];
    #   extraBuildCommands = ''
    #     mkdir opt
    #     ln -sf ${pkgs.chefdk} opt/chefdk
    #   '';
    # }).env
    chefdk = stdenv.mkDerivation {
      name = "chefdk-3.0.36";
      src = fetchurl (if stdenv.isDarwin then {
        url = "https://packages.chef.io/files/stable/chefdk/3.0.36/mac_os_x/10.13/chefdk-3.0.36-1.dmg";
        sha256 = "1r68s2ghglzq5rs9zb30bc4bd92x7fjr8vpxyafr8ibm99lisr7v";
      } else {
        url = "https://packages.chef.io/files/stable/chefdk/3.0.36/el/7/chefdk-3.0.36-1.el7.x86_64.rpm";
        sha256 = "0650vg8wy62ng4zk6r8vifnid0vnhnx452j4vqsf2zhfmm3j0pj0";
      });

      buildInputs = 
        [ cpio makeWrapper ] ++ 
        stdenv.lib.optional stdenv.isDarwin [ xar p7zip ] ++
        stdenv.lib.optional stdenv.isLinux [ rpm ];
      outputs = [ "out" "bin" ];

      phases = [ "unpack" "install" "postInstall"];

      unpack = if stdenv.isDarwin then ''
        7z x $src
        xar -xf Chef\ Development\ Kit/chefdk-3.0.36-1.pkg
      '' else ''
        rpm2cpio $src | cpio -i
      '';

      install = if stdenv.isDarwin then ''
        mkdir $out
        cat chefdk-core.pkg/Payload | gunzip -dc | cpio -i -D $out
      '' else ''
        cp -rfp opt/chefdk $out
      '';

      postInstall = ''
        binaries="berks chef chef-apply chef-shell chef-solo chef-vault
        cookstyle dco delivery foodcritic inspec kitchen knife ohai push-apply
        pushy-client pushy-service-manager chef-client"
        mkdir -p $bin/bin
        for i in $binaries; do
          ln -sf $out/bin/$i $bin/bin/$i
        done
      '';
    };
  };
}
