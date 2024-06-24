## This file will be copied to the /etc/nixos directory of the image,
## so it cannot have dependencies out of nixpkgs, home-manager, nix-effect-pod, and pod-configs.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  pod-configs = import ./pod-configs.nix;
  configuration = import "${pod-configs.nixEffectSource}/configuration.nix"  {
    inherit (pod-configs) homeManagerConfigurationSource homeManagerSource username userHome;
  };
in
{
  imports = [ configuration ];

  environment.systemPackages = with pkgs; [
    cacert
  ];

  programs = {
    zsh.enable = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # a commit on master
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/24492e6349a27e24ad998ad52f8b2e4e95d0eb62.tar.gz") {
      inherit pkgs;
    };
  };
}

