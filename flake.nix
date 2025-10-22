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
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/789dbebe144b5f7d29197d27de9a01125ffb2e4b";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-effect-pod.url = "github:hadilq/nix-effect-pod/main";
  };

  outputs =
    inputs@{
      determinate,
      nixpkgs,
      home-manager,
      darwin,
      nixpkgs-darwin,
      nixpkgs-unstable,
      nix-effect-pod,
      ...
    }:
    let
      localConfig = import ./.local/config.nix { };
      inherit (localConfig) system;
      mkHomeConfig =
        system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
          };

          modules = [
            ./linux/home.nix
          ];

          extraSpecialArgs = {
            inherit inputs system;
          } // { inherit localConfig pkgs-unstable; };
        };

      mkDarwinConfig =
        system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
          userName = localConfig.userName;
        in
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            nixpkgs = nixpkgs-darwin;
            inherit pkgs-unstable localConfig;
          };

          modules = [
            ./darwin/configuration.nix
            determinate.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.${userName} = import ./darwin/home.nix;
            }
          ];
        };

      pod-args = {
        nixEffectSource = "${nix-effect-pod}";
        pkgsSource = "${nixpkgs}";
        homeManagerSource = "${home-manager}";
      };
      development-pod = import ./pod-profiles/development/pod.nix pod-args;
      librewolf-pod = import ./pod-profiles/librewolf/pod.nix pod-args;

    in
    {
      homeConfigurations."${localConfig.userName}" = mkHomeConfig system;
      darwinConfigurations."${localConfig.userName}" = mkDarwinConfig system;

      pod.development = development-pod;
      pod.librewolf = librewolf-pod;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
