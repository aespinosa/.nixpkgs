with import <nixpkgs> {}; {
  sdlEnv = stdenv.mkDerivation {
    name = "rubyEnv";
    buildInputs = [ ruby ];
    GEM_HOME = "$out";
  };
}
