{
  packageOverrides = pkgs: rec {
    workstationEnv = pkgs.buildEnv {
      name = "workstation-environment";
      paths = with pkgs; [ screen gitMinimal tig ack zsh irssi macvim ];
    };
  };
}
