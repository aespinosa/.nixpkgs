{ stdenv, ruby, rake, makeWrapper, libiconv, zlib, glibcLocales }:

let

  foodcritic = stdenv.mkDerivation {
    name = "foodcritic-12.3.0";
    buildInputs = [ ruby makeWrapper libiconv zlib ];
    buildCommand = ''
       GEM_HOME=$out gem install --no-doc foodcritic --version 12.3.0 \
          --source http://nexus.dev:8081/repository/rubygems/
       rm -fv $out/bin/*
       makeWrapper ${ruby}/bin/ruby $out/bin/foodcritic \
          --add-flags $out/gems/foodcritic-12.3.0/bin/foodcritic \
          --set GEM_HOME $out
    '';

  };
  cookstyle = stdenv.mkDerivation {
    name = "cookstyle-2.1.0";
    buildInputs = [ ruby makeWrapper rake ];
    buildCommand = ''
       GEM_PATH=${rake} \
       GEM_HOME=$out gem install --no-doc cookstyle --version 2.1.0 \
          --source http://nexus.dev:8081/repository/rubygems/
       rm -rfv $out/bin/*
       makeWrapper ${ruby}/bin/ruby $out/bin/cookstyle \
          --add-flags $out/gems/cookstyle-2.1.0/bin/cookstyle \
          --set GEM_HOME $out
    '';
  };
  inspec = stdenv.mkDerivation {
    name = "inspec-1.31.1";
    buildInputs = [ ruby makeWrapper rake ];
    buildCommand = ''
       export GEM_PATH=${rake}
       GEM_HOME=$out gem install --no-doc inspec --version 1.31.1 \
          --source http://nexus.dev:8081/repository/rubygems/
       GEM_HOME=$out gem install --no-doc kitchen-inspec --version 0.19.0 \
          --source http://nexus.dev:8081/repository/rubygems/
       rm -fv $out/bin/*
       makeWrapper ${ruby}/bin/ruby $out/bin/inspec \
            --add-flags $out/gems/inspec-1.31.1/bin/inspec \
            --set GEM_HOME $out
    '';
  };
  chef-dk = stdenv.mkDerivation {
    name = "chef-dk-2.1.11";
    buildInputs = [ ruby makeWrapper ];

    buildCommand = ''
       GEM_HOME=$out gem install --no-doc molinillo --version 0.5.7 \
          --source http://nexus.dev:8081/repository/rubygems/
       GEM_HOME=$out gem install --no-doc chef-dk --version 2.1.11 \
          --source http://nexus.dev:8081/repository/rubygems/
       rm -fv $out/bin/*
       makeWrapper ${ruby}/bin/ruby $out/bin/chef \
          --add-flags $out/gems/chef-dk-2.1.11/bin/chef \
          --set GEM_HOME $out
    '';
  };

  test-kitchen = stdenv.mkDerivation {
    name = "test-kitchen-1.16.0";

    buildInputs = [ ruby makeWrapper ];

    buildCommand = ''
       GEM_HOME=$out gem install --no-doc test-kitchen --version 1.16.0 \
          --source http://nexus.dev:8081/repository/rubygems/
       GEM_HOME=$out gem install --no-doc kitchen-vagrant --version 1.1.1 \
          --source http://nexus.dev:8081/repository/rubygems/
       GEM_HOME=$out gem install --no-doc kitchen-google --version 1.2.0 \
          --source http://nexus.dev:8081/repository/rubygems/

       rm -fv $out/bin/mixlib-install $out/bin/safe_yaml $out/bin/thor 

       makeWrapper ${ruby}/bin/ruby $out/bin/kitchen \
          --add-flags $out/gems/test-kitchen-1.16.0/bin/kitchen \
          --set GEM_HOME $out
    '';
  };

  stove = stdenv.mkDerivation {
    name = "stove-5.2.0";

    buildInputs = [ ruby makeWrapper ];

    buildCommand = ''
      GEM_HOME=$out gem install --no-doc stove --version 5.2.0 \
         --source http://nexus.dev:8081/repository/rubygems/

      rm -fv $out/bin/*

      makeWrapper ${ruby}/bin/ruby $out/bin/stove \
         --add-flags $out/gems/stove-5.2.0/bin/stove \
         --set GEM_HOME $out
   '';
  };
in
stdenv.mkDerivation {
  name = "chef-environment";
  buildInputs = [ test-kitchen chef-dk cookstyle inspec foodcritic ]
    ++ stdenv.lib.optional (stdenv.isLinux) glibcLocales;
  buildCommand = ''
    mkdir -p $out/bin
    ln -sf ${test-kitchen}/bin/kitchen $out/bin
    ln -sf ${chef-dk}/bin/chef $out/bin
    ln -sf ${cookstyle}/bin/cookstyle $out/bin
    ln -sf ${inspec}/bin/inspec $out/bin
    ln -sf ${foodcritic}/bin/foodcritic $out/bin
    ln -sf ${stove}/bin/stove $out/bin
    fixupPhase
    '';
}
