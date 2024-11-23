## This file will be copied to the /etc/nixos directory of the image,
## so it cannot have dependencies out of nixpkgs, home-manager, nix-effect-pod, and pod-configs.
{
  pkgs,
  ...
}:
let
  pod-configs = import ./pod-configs.nix;
  configuration = import "${pod-configs.nixEffectSource}/configuration.nix"  {
    inherit (pod-configs) homeManagerConfigurationSource homeManagerSource uname userHome;
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
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/1bfee5e55992301948598f3bb5192e58dfb53cc2.tar.gz") {
      inherit pkgs;
    };
  };
}

