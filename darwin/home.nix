{ config, pkgs, lib, localConfig, ... }:
let
  inherit (pkgs) stdenv;

  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;

  zsh-nix = import ./pod-profiles/common/zsh.nix {
    initExtra = ''
      export PATH=$PATH:/usr/local/bin
      HISTSIZE=20000
    '';
  };
  neovim-nix = import ./../pod-profiles/common/neovim.nix { };
in {
  imports = [
    ./../pod-profiles/common/vim.nix
    ./../pod-profiles/common/gpg.nix
    ./../pod-profiles/common/git.nix
    ./../pod-profiles/common/shell-tools.nix
    ./../pod-profiles/common/tmux.nix
    zsh-nix
    neovim-nix
  ];
  programs.home-manager.enable = true;

  home.username = userName;
  home.homeDirectory = homeDirectory;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.stateVersion = "25.05";

  fonts.fontconfig.enable = true;

  programs.gpg.enable = true;

  home.packages = with pkgs; [
    curl
    nmap
    inetutils # telnet
    htop
    fd
    ripgrep
    glab
    gh
    lua-language-server
    nixd # nix language server
    pass
    python3
    openssl
    zulu17
  ];
}
