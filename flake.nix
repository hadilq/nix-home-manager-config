{
  description = "Nix desktop configs";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixarchy = {
      url = "github:olafkfreund/nixarchy/release";
      inputs.nixpkgs.follows = "nixpkgs";
      # Build Hyprland (and the Mesa paired with it) against our nixpkgs
      # instead of the older nixpkgs pinned by Hyprland's flake, which
      # carried brotli 1.2.0 (CVE-2026-111497). Costs a local Hyprland build.
      inputs.hyprland.inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-effect-pod.url = "github:hadilq/nix-effect-pod/main";
    sops-nix = {
      url = "github:Mic92/sops-nix/c591bf665727040c6cc5cb409079acb22dcce33c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    grok-bot = {
      url = "github:jordangarrison/grok-bot-flake/0a550659fae0e9bc0f2b8d7eb4722e82042583f0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Local checkout for now; once pushed, switch to e.g.
    #   url = "github:hadilq/secret-broker";
    secret-broker = {
      url = "path:/home/hadi/dev/secret-broker";
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
      nixarchy,
      nix-effect-pod,
      sops-nix,
      grok-bot,
      secret-broker,
      ...
    }:
    let
      localConfig = import ./.local-config.nix;
      inherit (localConfig) system;
      pkgs = import nixpkgs {
        inherit system;
      };
      commonPodConfigs = import ./pod-profiles/modules/common-pod-configs.nix;
      mkHomeConfig =
        system:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./linux/home.nix
            nixarchy.homeManagerModules.nixarchy
            secret-broker.homeManagerModules.default
          ];

          extraSpecialArgs = {
            inherit inputs system;
          }
          // {
            inherit localConfig pkgs-unstable grok-bot;
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
