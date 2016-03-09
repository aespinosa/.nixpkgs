{ stdenv, fetchurl, callPackage }:

let 
  plistService = callPackage ./plist.nix {};
  logDir = "/usr/local/var/log";
  jenkins2 = stdenv.mkDerivation {
    name = "jenkins-2.0-alpha";
    src = fetchurl {
      url = "http://mirrors.jenkins-ci.org/war-rc/2.0/jenkins.war";
      sha256 = "133r6z38gmllr7373gz85j9k5c7gdiz9p8c072dkrmwfzyxf51jx";
    };

    buildCommand = "ln -sf $src $out";
  }; in

plistService {
  name = "jenkins";
  programArgs = [ "java" "-jar" "${jenkins2}" ];
  stdout = "${logDir}/jenkins.log";
  stderr = "${logDir}/jenkins.log";
}
