{
  pkgs,
  localConfig,
  ...
}:
let

  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;

  zsh-nix = import ../pod-profiles/modules/zsh.nix { };
  helix-nix = import ../pod-profiles/modules/helix.nix { };
in
{
  imports = [
    ../pod-profiles/modules/vim.nix
    ../pod-profiles/modules/gpg.nix
    ../pod-profiles/modules/git.nix
    ../pod-profiles/modules/shell-tools.nix
    ../pod-profiles/modules/tmux.nix
    ./librewolf.nix
    zsh-nix
    helix-nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = userName;
  home.homeDirectory = homeDirectory;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  home.packages = with pkgs; [
    curl
    nmap
    inetutils # telnet
    htop
    fd
    ripgrep
    glab
    git-crypt
    git-lfs
    gh
    lua-language-server
    nixd # nix language server
    pass
  ];

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
