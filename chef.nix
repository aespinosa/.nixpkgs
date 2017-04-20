{ stdenv, ruby, makeWrapper }:

let
  chef-dk = stdenv.mkDerivation {
    name = "chef-dk-1.2.22";
    buildInputs = [ ruby makeWrapper ];

    buildCommand = ''
       GEM_HOME=$out gem install --no-doc chef-dk --version 1.2.22 \
          --source http://nexus.dev:8081/repository/rubygems/
       rm -fv $out/bin/*
       makeWrapper ${ruby}/bin/ruby $out/bin/chef \
          --add-flags $out/gems/chef-dk-1.2.22/bin/chef \
          --set GEM_HOME $out
    '';
  };
  test-kitchen = stdenv.mkDerivation {
    name = "test-kitchen-1.16.0";

    buildInputs = [ ruby makeWrapper ];

    buildCommand = ''
       GEM_HOME=$out gem install --no-doc test-kitchen --version 1.16.0 \
          --source http://nexus.dev:8081/repository/rubygems/
       GEM_HOME=$out gem install --no-doc kitchen-vagrant --version 1.0.2 \
          --source http://nexus.dev:8081/repository/rubygems/

       rm -fv $out/bin/mixlib-install $out/bin/safe_yaml $out/bin/thor 

       makeWrapper ${ruby}/bin/ruby $out/bin/kitchen \
          --add-flags $out/gems/test-kitchen-1.16.0/bin/kitchen \
          --set GEM_HOME $out
    '';
  };
in
stdenv.mkDerivation {
  name = "chef-environment";
  buildInputs = [ test-kitchen chef-dk ];
}
