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
  configuration = import "${pod-configs.nixEffectSource}/configuration.nix" {
    inherit (pod-configs) homeManagerConfigurationSource homeManagerSource username userHome;
  };
  nvidia_x11 = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs {
    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/535.183.01/NVIDIA-Linux-x86_64-535.183.01.run";
      hash = "sha256-9nB6+92pQH48vC5RKOYLy82/AvrimVjHL6+11AXouIM=";
    };
  };

in
{
  imports = [ configuration ];

  programs = {
    zsh.enable = true;
    git.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      nvidia_x11
    ];

    variables = {
      LD_LIBRARY_PATH = "/usr/lib64"; # It's needed by nvidia-smi
    };
  };
}

