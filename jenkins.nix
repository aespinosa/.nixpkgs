{ stdenv, fetchurl, callPackage }:


let 
  plistService = callPackage ./plist.nix {};
  logDir = "/usr/local/var/log";
  jenkins2 = stdenv.mkDerivation rec {
    name = "jenkins-${version}";
    version = "2.0-beta-2";
    src = fetchurl {
      url = "http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${version}/jenkins-war-${version}.war";
      sha256 = "1nhz99fzgnm8v8s6p4wb7fry9495mwrzbivpmp5yj2aj43wpxick";
    };

    buildCommand = "ln -sf $src $out";
  }; in

plistService {
  name = "jenkins";
  programArgs = [ "java" "-jar" "${jenkins2}" ];
  stdout = "${logDir}/jenkins.log";
  stderr = "${logDir}/jenkins.log";
}
