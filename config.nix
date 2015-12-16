{ pkgs }:

{
  packageOverrides = pkgs: with pkgs; rec {
    workstationEnv = buildEnv {
      name = "workstation-environment";
      paths = [ screen gitMinimal tig ack zsh irssi macvim ];
    };

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
      buildInputs = [ net-ssh ];
    };

    test-kitchen = buildRubyGem {
      name = "test-kitchen-1.4.2";
      sha256 = "017fify4hnk9rn4i7165x80xamsp6n2rb85j31s9ggb57xjv7bvs";
      buildInputs = [ thor mixlib-shellout safe_yaml net-ssh net-scp ];
    };

  };
}
