{
  description = "Nix desktop configs";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.11.1";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/8158addeaeb69921e8b474a81fafb7d97ded2850";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs@{ determinate, nixpkgs, home-manager, darwin, nixpkgs-unstable, ... }:
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

      mkDarwinConfig = system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
          userName = localConfig.userName;
        in darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit nixpkgs pkgs-unstable;
            };

            modules = [
              ./darwin/configuration.nix
              determinate.darwinModules.default
              home-manager.darwinModules.home-manager
              {
                home-manager.useUserPackages = true;
                home-manager.users.${userName} = import ./darwin/home.nix;

                home-manager.extraSpecialArgs = {
                  inherit nixpkgs pkgs-unstable;
                };
              }
            ];
          };

    in {
      homeConfigurations."${localConfig.userName}" = mkHomeConfig localConfig.system;
      darwinConfigurations."${localConfig.userName}" = mkDarwinConfig localConfig.system;
    };
}

