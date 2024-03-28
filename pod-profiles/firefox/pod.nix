{ system ? "x86_64-linux"
  # release-23.11
, pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/eba152efd59ab71f1552f201b6c3a5016759a40d.tar.gz") {
    inherit system;
  }
, home-manager-source ? builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/2f9728fb7eeddfec67cb167b86118564eda33e62.tar.gz"
, name ? "firefox-machine"
, nixosConfiguration ? ./configuration.nix
, homeManagerConfiguration ? ./home.nix
, nixpkgsChannelURL ? "https://nixos.org/channels/nixos-23.11-small"
, homeChannelURL ? "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz"
, username ? "dev"
, userHome ? "/home/dev"
, lib ? pkgs.lib
, nixos ? (import  "${pkgs.path}/nixos" {
    configuration = { config, pkgs, modulesPath, ... }: {
      imports = [
        "${toString modulesPath}/virtualisation/docker-image.nix"
        (import nixosConfiguration)
        (import "${home-manager-source}/nixos")
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = { config, pkgs, lib, ... } :{
          imports = [
            (import homeManagerConfiguration)
          ];

          programs.home-manager.enable = true;
          home.username = username;
          home.homeDirectory = userHome;

          home.stateVersion = "23.11";
        };
      };

      boot.isContainer = true;
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      services.journald.console = "/dev/console";

      services.xserver.enable = true;
      services.xserver.layout = "us";
      services.xserver.displayManager.lightdm.enable = true;

      users = {
        mutableUsers = true;
        users = {
          ${username} = {
            isNormalUser = true;
            home = userHome;
            description = "Development";
            extraGroups = [ ];
	          shell = pkgs.bashInteractive;
          };
        };
      };

      time.timeZone = "Canada/Eastern";
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "JetBrainsMono Nerd Font";
        keyMap = "us";
      };

      environment.systemPackages = with pkgs; [
        nix
        bashInteractive
        coreutils-full
        gnutar
        gnugrep
        gzip
        which
        curl
        less
        man
        cacert
        vim
        nmap
        ca
        p11kit
      ];

      fonts.fonts = with pkgs; [
        nerdfonts
      ];

      system.stateVersion = "23.11";
    };
    inherit system;
  })
}:
let
  image = (import ../pod.nix {
    inherit system pkgs home-manager-source name nixosConfiguration homeManagerConfiguration
      nixpkgsChannelURL homeChannelURL;
  });
in
image
