{
  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      localConfig = import ./.local/config.nix { };
      mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        modules = [
          ./home.nix
        ];

        extraSpecialArgs = {
          inherit inputs system;
        } // { inherit localConfig; };
      };
    in {
      homeConfigurations."${localConfig.userName}" = mkHomeConfig localConfig.system;
    };
}

