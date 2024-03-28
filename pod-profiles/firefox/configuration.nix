{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    zsh.enable = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # a commit on master
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/24492e6349a27e24ad998ad52f8b2e4e95d0eb62.tar.gz") {
      inherit pkgs;
    };
  };

  security.pki = {
    installCACerts = true;
    certificateFiles = [ "/etc/ipsec.d/cacerts" ];
  };
}


