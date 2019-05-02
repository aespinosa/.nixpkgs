{ stdenv, fetchurl, cpio, makeWrapper, xar, p7zip, rpm }:

stdenv.mkDerivation {
  name = "chefdk";
  src = fetchurl (if stdenv.isDarwin then {
    url = "https://packages.chef.io/files/stable/chefdk/3.1.0/mac_os_x/10.13/chefdk-3.1.0-1.dmg";
    sha256 = "06k12nm63w5cib0gxcs2v7x7v158ip7dxxb59jl19qddn385r6k6";
  } else {
    # url = "https://packages.chef.io/files/stable/chefdk/1.2.22/el/7/chefdk-1.2.22-1.el7.x86_64.rpm";
    # sha256 = "1qmgkcp133kk14b6r8d9yn2fzigamhgf1z7qhd0bya9fndh4anm8";
    url = "https://packages.chef.io/files/stable/chefdk/3.1.0/el/7/chefdk-3.1.0-1.el7.x86_64.rpm";
    sha256 = "10lsizb68jafjnfccdq08h17p1flkrw9kjpqanh04dkkvpcw55ix";
  });

  buildInputs = 
  [ cpio makeWrapper ] ++ 
  stdenv.lib.optional stdenv.isDarwin [ xar p7zip ] ++
  stdenv.lib.optional stdenv.isLinux [ rpm ];
  outputs = [ "out" "bin" ];

  phases = [ "unpack" "install" "postInstall" "fixupPhase" ];

  unpack = if stdenv.isDarwin then ''
        7z x $src
        xar -xf Chef\ Development\ Kit/chefdk-3.0.36-1.pkg
  '' else ''
        rpm2cpio $src | cpio -i
  '';

  install = if stdenv.isDarwin then ''
        mkdir $out
        cat chefdk-core.pkg/Payload | gunzip -dc | cpio -i -D $out
  '' else ''
        cp -rvfp opt/chefdk $out
  '';

  postInstall = ''
        binaries="berks chef chef-apply chef-shell chef-solo chef-vault
        cookstyle dco delivery foodcritic inspec kitchen knife ohai push-apply
        pushy-client pushy-service-manager chef-client"
        mkdir -p $bin/bin
        for i in $binaries; do
          ln -sf $out/bin/$i $bin/bin/$i
        done
  '';

  fixupPhase = ''
        set -x
        patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/embedded/bin/ruby
        patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/bin/delivery
  '';
}
