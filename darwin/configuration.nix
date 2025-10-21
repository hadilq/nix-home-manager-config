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
in
{
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
    settings = {
      ssl-cert-file = "/etc/nix/ca_cert.pem";
    };
    extraOptions = ''
      auto-optimize-store = true
    '';
  };

  programs.zsh.enable = true;

  system.stateVersion = 4;
}
