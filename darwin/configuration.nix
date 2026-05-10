{
  config,
  pkgs,
  lib,
  localConfig,
  pkgs-unstable,
  ...
}:
let
  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;
  sops-nix = import ../pod-profiles/modules/sops.nix { };
in
{
  imports = [
      # sops-nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      vscode = pkgs-unstable.vscode;
    };
  };

  users.users."${userName}" = {
    home = homeDirectory;
  };

  ids.gids.nixbld = 350;

  nix = {
    enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      ssl-cert-file = "/etc/nix/ca_cert.pem";
      auto-optimize-store = true;
    };
  };

  system.primaryUser = userName;
  homebrew = {
    enable = true;

    taps = [ ];
    brews = [ ];
    casks = [
      "google--chrome" "jetbrain-toolbox"
    ];
  };

  programs.zsh.enable = true;

  system.stateVersion = 4;
}
