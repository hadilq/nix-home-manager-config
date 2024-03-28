{ system ? "x86_64-linux"
  # release-23.11
, pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/eba152efd59ab71f1552f201b6c3a5016759a40d.tar.gz") {
    inherit system;
  }
, home-manager-source ? builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/2f9728fb7eeddfec67cb167b86118564eda33e62.tar.gz"
, name ? "dev-machine"
, nixosConfiguration ? ./configuration.nix
, homeManagerConfiguration ? ./home.nix
, nixpkgsChannelURL ? "https://nixos.org/channels/nixos-23.11-small"
, homeChannelURL ? "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz"
}:
let
  image = (import ../pod.nix {
    inherit system pkgs home-manager-source name nixosConfiguration homeManagerConfiguration
      nixpkgsChannelURL homeChannelURL;
  });
in
image
