{ stdenv, fetchurl, callPackage }:


let 
  plistService = callPackage ./plist.nix {};
  logDir = "/usr/local/var/log";
  jenkins2 = stdenv.mkDerivation {
    name = "jenkins-2.0-alpha-3";
    src = fetchurl {
      url = "http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/2.0-alpha-3/jenkins-war-2.0-alpha-3.war";
      sha256 = "1m7f55ism5kywx85s842mjb50za77fs70jxhnj9lx2dhlcp4ym9w";
    };

    buildCommand = "ln -sf $src $out";
  }; in

plistService {
  name = "jenkins";
  programArgs = [ "java" "-jar" "${jenkins2}" ];
  stdout = "${logDir}/jenkins.log";
  stderr = "${logDir}/jenkins.log";
}
