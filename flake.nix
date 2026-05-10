{
  description = "Nix desktop configs";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.13";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/16fe302dbbe623329e96b2f0b33dc4d557803aaa";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-effect-pod.url = "github:hadilq/nix-effect-pod/main";
    sops-nix = {
      url = "github:Mic92/sops-nix/c591bf665727040c6cc5cb409079acb22dcce33c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      sops-nix,
      ...
    }:
    let
      localConfig = import ./.local/config.nix { };
      commonPodConfigs = import ./pod-profiles/modules/common-pod-configs.nix;
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
          }
          // {
            inherit localConfig pkgs-unstable;
          };
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
              home-manager.users.${userName} = ./darwin/home.nix;
              home-manager.extraSpecialArgs = {
                nixpkgs = nixpkgs-darwin;
                inherit pkgs-unstable localConfig;
              };
            }
            sops-nix.darwinModules.sops
          ];
        };

      pod-configs = {
        inherit system;
        nixEffectSource = nix-effect-pod.path;
        pkgsSource = "${nixpkgs}";
        homeManagerSource = "${home-manager}";
        gitEmail = localConfig.gitEmail;
        gitName = localConfig.gitName;
      };

      development-pod = import "${pod-configs.nixEffectSource}/modules/pod.nix" (
        pod-configs // commonPodConfigs // import ./pod-profiles/development/pod-configs.nix
      );
      development-gpu-pod = import "${pod-configs.nixEffectSource}/modules/pod.nix" (
        pod-configs // commonPodConfigs // import ./pod-profiles/development-gpu/pod-configs.nix
      );
      librewolf-pod = import "${pod-configs.nixEffectSource}/modules/pod.nix" (
        pod-configs // commonPodConfigs // import ./pod-profiles/librewolf/pod-configs.nix
      );
    in
    {
      homeConfigurations."${localConfig.userName}" = mkHomeConfig system;
      darwinConfigurations."${localConfig.userName}" = mkDarwinConfig system;

      pod.development = development-pod;
      pod.development-gpu = development-gpu-pod;
      pod.librewolf = librewolf-pod;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
