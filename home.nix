{ config, pkgs, lib, localConfig, ... }:
let
  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;
  zsh-nix = import ./pod-profiles/common/zsh.nix {
    initExtra = lib.mkIf stdenv.isDarwin ''
      export PATH=$PATH:/usr/local/bin
      HISTSIZE=10000
    '';
  };
  neovim-nix = import ./pod-profiles/common/neovim.nix { };
  helix-nix = import ./pod-profiles/common/helix.nix { };
  inherit (pkgs) stdenv;
in
{
  imports = [
    ./gnome.nix
    ./pod-profiles/common/vim.nix
    ./pod-profiles/common/gpg.nix
    ./pod-profiles/common/shell-tools.nix
    ./pod-profiles/common/tmux.nix
    zsh-nix
    neovim-nix
    helix-nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

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
    bitwarden-cli
    glab
    git-crypt
    git-lfs
    gh
    nerdfonts
    imagemagick
    lua-language-server
    nixd # nix language server
  ] ++ lib.optionals stdenv.isDarwin [
    (import ./brew-installer-derivation { inherit stdenv; inherit pkgs; } homeDirectory)
  ] ++ lib.optionals stdenv.isLinux [
    aspell
    aspellDicts.en
    aspellDicts.ca
    firefox
    thunderbird
    vlc
    audacity
    keepassxc
    libreoffice
    gimp
    yakuake
    gdrive
    bitwarden
    virt-manager
    krfb
    neovim-qt
    inkscape
    pulseaudioFull
    gsound
    libgda6
  ];

  fonts.fontconfig.enable = true;


  # The rest of the configurations are inside the zsh.nix file
  programs.zsh = {
    shellAliases = {
      ff = "/Applications/Firefox.app/Contents/MacOS/firefox -P --no-remote&";
    };

    shellGlobalAliases = {
      python-default-shell = "nix-shell $HOME/.config/home-manager/python-default-shell.nix";
      nodejs-default-shell = "nix-shell $HOME/.config/home-manager/nodejs-default-shell.nix";
      ruby-default-shell = "nix-shell $HOME/.config/home-manager/ruby-default-shell.nix";
      jupyter-default-shell = "nix-shell $HOME/.config/home-manager/jupyter-default-shell.nix";
    };

    initExtraBeforeCompInit = lib.mkIf stdenv.isDarwin ''
      . $HOME/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        editor = "hx";
      };
      credential.helper = lib.optionals stdenv.isDarwin "osxkeychain";
    };

    includes = [{
      contents = {
        init.defaultBranch = "main";
        user = {
          email = localConfig.gitEmail;
          name = localConfig.gitName;
          signingKey = localConfig.gitSigningKey;
        };
        commit = {
          gpgSign = true;
        };
      };
    }];
  };

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

