{ stdenv, fetchurl, callPackage }:


let 
  plistService = callPackage ./plist.nix {};
  logDir = "/usr/local/var/log";
  jenkins2 = stdenv.mkDerivation rec {
    name = "jenkins-${version}";
    version = "2.0-rc-1";
    src = fetchurl {
      url = "http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${version}/jenkins-war-${version}.war";
      sha256 = "14ahpz3613pbzsi8mxhj5c5lfv96a5w89ibr2mrqbw7rarw0hbfr";
    };

    buildCommand = "ln -sf $src $out";
  }; in

plistService {
  name = "jenkins";
  programArgs = [ "java" "-jar" "${jenkins2}" ];
  stdout = "${logDir}/jenkins.log";
  stderr = "${logDir}/jenkins.log";
}
