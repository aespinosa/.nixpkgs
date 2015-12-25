{ pkgs }:

{
  packageOverrides = pkgs: with pkgs; rec {
    workstationEnv = buildEnv {
      name = "workstation-environment";
      paths = [ screen gitMinimal tig ack zsh irssi macvim ];
    };

    #packer = pkgs.packer.override {
      #go = pkgs.go_1_4;
    #};

    # begin test-kitchen
    mixlib-shellout = buildRubyGem {
      name = "mixlib-shellout-2.2.5";
      sha256 = "1is07rar0x8n9h67j4iyrxz2yfgis4bnhh3x7vhbbi6khqqixg79";
    };

    safe_yaml = buildRubyGem { 
      name = "safe_yaml-1.0.4";
      sha256 = "1hly915584hyi9q9vgd968x2nsi5yag9jyf5kq60lwzi5scr7094";
    };

    thor = buildRubyGem {
      name = "thor-0.19.1";
      sha256 = "08p5gx18yrbnwc6xc0mxvsfaxzgy2y9i78xq7ds0qmdm67q39y4z";
    };

    net-ssh = buildRubyGem {
      name = "net-ssh-2.9.2";
      sha256 = "1p0bj41zrmw5lhnxlm1pqb55zfz9y4p9fkrr9a79nrdmzrk1ph8r";
    };

    net-scp = buildRubyGem {
      name = "net-scp-1.2.1";
      sha256 = "0b0jqrcsp4bbi4n4mzyf70cp2ysyp6x07j8k8cqgxnvb4i3a134j";
    };

    test-kitchen = buildRubyGem {
      name = "test-kitchen-1.4.2";
      sha256 = "017fify4hnk9rn4i7165x80xamsp6n2rb85j31s9ggb57xjv7bvs";
      buildInputs = [ thor mixlib-shellout safe_yaml net-ssh net-scp ];
    };

    kitchen-vagrant = buildRubyGem {
      name = "kitchen-vagrant-0.19.0";
      sha256 = "0sydjihhvnr40vqnj7bg65zxf00crwvwdli1av03ghhggrp5scla";
    };

    # begin berkshelf

    addressable = buildRubyGem {
      name = "addressable-2.3.8";
      sha256 = "1533axm85gpz267km9gnfarf9c78g2scrysd6b8yw33vmhkz2km6";
    };

    buff-config = buildRubyGem {
      name = "buff-config-1.0.1";
      sha256 = "0r3h3mk1dj7pc4zymz450bdqp23faqprx363ji4zfdg8z6r31jfh";
    };

    buff-extensions = buildRubyGem {
      name = "buff-extensions-1.0.0";
      sha256 = "1jqb5sn38qgx66lc4km6rljzz05myijjw12hznz1fk0k4qfw6yzk";
    };

    buff-ignore = buildRubyGem {
      name = "buff-ignore-1.1.1";
      sha256 = "1ghzhkgbq7f5fc7xilw0c9gspxpdhqhq3ygi1ybjm6r0dxlmvdb4";
    };

    buff-ruby_engine = buildRubyGem {
      name = "buff-ruby_engine-0.1.0";
      sha256 = "1llpwpmzkakbgz9fc3vr1298cx1n9zv1g25fwj80xnnr7428aj8p";
    };

    buff-shell_out = buildRubyGem {
      name = "buff-shell_out-0.2.0";
      sha256 = "0sphb69vxm346ys2laiz174k5jx628vfwz9ch8g2w9plc4xkxf3p";
    };

    celluloid = buildRubyGem {
      name = "celluloid-0.16.0";
      sha256 = "044xk0y7i1xjafzv7blzj5r56s7zr8nzb619arkrl390mf19jxv3";
    };

    celluloid-io = buildRubyGem {
      name = "celluloid-io-0.16.2";
      sha256 = "1l1x0p6daa5vskywrvaxdlanwib3k5pps16axwyy4p8d49pn9rnx";
      buildInputs = [ celluloid ];
    };

    cleanroom = buildRubyGem {
      name = "cleanroom-1.0.0";
      sha256 = "1r6qa4b248jasv34vh7rw91pm61gzf8g5dvwx2gxrshjs7vbhfml";
    };

    dep-selector-libgecode = buildRubyGem {
      name = "dep-selector-libgecode-1.0.2";
      sha256 = "0755ps446wc4cf26ggmvibr4wmap6ch7zhkh1qmx1p6lic2hr4gn";
      USE_SYSTEM_GECODE = true;
      buildInputs = [ perl ];
    };

    dep_selector = buildRubyGem {
      name = "dep_selector-1.0.3";
      sha256 = "1ic90j3d6hmyxmdxzdz8crwmvw61f4kj0jphk43m6ipcx6bkphzw";
      buildInputs = [ ffi dep-selector-libgecode darwin.libobjc ];
    };

    ffi = buildRubyGem {
      name = "ffi-1.9.10";
      sha256 = "1m5mprppw0xcrv2mkim5zsk70v089ajzqiq5hpyb0xg96fcyzyxj";
      buildInputs = [ libffi darwin.libobjc ];
    };

    nio4r = buildRubyGem {
      name = "nio4r-1.1.1";
      sha256 = "17lm816invs85rihkzb47csj3zjywjpxlfv2zba2z63ji2gzv1jx";
      buildInputs = [ darwin.libobjc ];
    };


    hitimes = buildRubyGem {
      name = "hitimes-1.2.3";
      sha256 = "1fr9raz7652bnnx09dllyjdlnwdxsnl0ig5hq9s4s8vackvmckv4";
      buildInputs = [ darwin.apple_sdk.frameworks.CoreServices darwin.libobjc ];
    };

    timers = buildRubyGem {
      name = "timers-4.0.4";
      sha256 = "1jx4wb0x182gmbcs90vz0wzfyp8afi1mpl9w5ippfncyk4kffvrz";
    };

    erubis = buildRubyGem { 
      name = "erubis-2.7.0";
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
    };

    hashie = buildRubyGem {
      name = "hashie-3.4.3";
      sha256 = "1iv5hd0zcryprx9lbcm615r3afc0d6rhc27clywmhhgpx68k8899";
    };

    varia_model = buildRubyGem {
      name = "varia_model-0.4.1";
      sha256 = "1qm9fhizfry055yras9g1129lfd48fxg4lh0hck8h8cvjdjz1i62";
      buildInputs = [ buff-extensions hashie ];
    };

    ridley = buildRubyGem {
      name = "ridley-4.3.2";
      sha256 = "06rz034xwyz3rgn1hjv4hsw6ywxya44yzvgghpszn22gj22whvj9";
      buildInputs = [ addressable varia_model buff-config buff-ignore
                      buff-shell_out celluloid-io erubis ];
    };

    berkshelf = buildRubyGem {
      name = "berkshelf-4.0.1";
      sha256 = "14mh88lzpmlsc2q2m611pd3vyvxnhi16klnnrbg5ccrdl7xn4l4a";
      buildInputs = [ buff-extensions cleanroom ridley buff-config
                      buff-shell_out celluloid celluloid-io ]
         ++ [ addressable varia_model buff-ignore erubis ] # ridley
         ++ [ hashie ] # varia_model
         ++ [ buff-ruby_engine ] # buff-shell_out
         ++ [ timers ] # celluoid
         ++ [ hitimes ] # timers
         ++ [ nio4r ] # celluloid-io
         ;
    };

    chefEnv = buildEnv {
      name = "chefEnv";
      paths = [ test-kitchen kitchen-vagrant berkshelf ];
      #pathsToLink = [ "/bin" ];
    };
    #    buildRubyGem = null;
  };
}
