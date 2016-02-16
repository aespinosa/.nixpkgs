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

    plistService = callPackage ./plist.nix {};

    logDir = "/usr/local/var/log";

    jenkinsService = plistService {
      name = "jenkins";
      programArgs = [ "java" "-jar" "${jenkins}" ];
      stdout = "${logDir}/jenkins.log";
      stderr = "${logDir}/jenkins.log";
    };

  };
}
