## This file will be copied to the /etc/nixos directory of the image,
## so it cannot have dependencies out of pod-configs.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  pod-configs = import ./pod-configs.nix;
  configuration = import "${pod-configs.nixEffectSource}/configuration.nix" {
    inherit (pod-configs) homeManagerConfigurationSource homeManagerSource username userHome;
  };
in
{
  imports = [ configuration ];

  programs = {
    zsh.enable = true;
    git.enable = true;
  };
}

