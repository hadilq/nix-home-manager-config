{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/8158addeaeb69921e8b474a81fafb7d97ded2850";
  };

  outputs = inputs@{ nixpkgs, home-manager, nixpkgs-unstable, ... }:
    let
      localConfig = import ./.local/config.nix { };
      mkHomeConfig = system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
        in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
          };

          modules = [
            ./home.nix
          ];

          extraSpecialArgs = {
            inherit inputs system;
          } // { inherit localConfig pkgs-unstable; };
        };
    in {
      homeConfigurations."${localConfig.userName}" = mkHomeConfig localConfig.system;
      # To be used in other distributions like Ubuntu.
      defaultPackage = home-manager.defaultPackage;
    };
}

