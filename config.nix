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
      buildInputs = [ ruby darwin.apple_sdk.frameworks.CoreServices
                      darwin.libobjc];
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
  };
}
