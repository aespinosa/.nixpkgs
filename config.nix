{ pkgs }:

{
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
      buildInputs = [ ruby_2_1_6 darwin.apple_sdk.frameworks.CoreServices
                      darwin.libobjc];
      shellHook = ''
        export GEM_HOME=$out
        export PATH=$GEM_HOME/bin:$PATH
      '';
    };

    jenkins2 = stdenv.mkDerivation {
      name = "jenkins-2.0-alpha";
      src = fetchurl {
        url = "http://mirrors.jenkins-ci.org/war-rc/2.0/jenkins.war";
        sha256 = "133r6z38gmllr7373gz85j9k5c7gdiz9p8c072dkrmwfzyxf51jx";
      };

      buildCommand = "ln -sf $src $out";
    };

    plistService = callPackage ./plist.nix {};

    logDir = "/usr/local/var/log";

    jenkinsService = plistService {
      name = "jenkins";
      programArgs = [ "java" "-jar" "${jenkins2}" ];
      stdout = "${logDir}/jenkins.log";
      stderr = "${logDir}/jenkins.log";
    };

    deisCtl = stdenv.mkDerivation {
      name = "deisctl-1.12.3";
      buildInputs = [ makeWrapper ];
      src = fetchurl {
        url = "https://github.com/deis/deis/releases/download/v1.12.3/deisctl-1.12.3-darwin-amd64.run";
        sha256 = "0cia0w60d6xwjnsfij8nh4dq3jwzgyvl9mia4qcinv0h9axb53f3";
      };

      phases = [ "unpackPhase" "installPhase" ];

      unpackPhase = ''
        bash $src --noexec
      '';

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/libexec
        cp deisctl $out/libexec/deisctl
        mkdir -p $out/lib/deis/units
        makeWrapper $out/libexec/deisctl $out/bin/deisctl --set DEISCTL_TUNNEL $out/lib/deis/units

        $out/bin/deisctl refresh-units -p $out/lib/deis/units 
      '';
    };

    deisEnv = stdenv.mkDerivation {
      name = "deisEnvironment";
      buildInputs = [ awscli deisCtl ];
    };
  };
}
