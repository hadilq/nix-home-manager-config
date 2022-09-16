{ config, pkgs, lib, ... }:
let
  localConfig = import ./.local/config.nix {};
  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;
  inherit (pkgs) stdenv;

  androidComposition = lib.optionals stdenv.isLinux pkgs.androidenv.composeAndroidPackages {
    platformToolsVersion = "31.0.3";
    buildToolsVersions = [ "30.0.3" "31.0.0" ];
    includeEmulator = false;
    platformVersions = [ "28" "29" "30" ];
    includeSources = true;
    includeSystemImages = false;
    cmakeVersions = [ "3.10.2" ];
    includeNDK = true;
    ndkVersions = ["22.0.7026061"];
    useGoogleAPIs = false;
  };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = userName;
  home.homeDirectory = homeDirectory;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  home.packages = with pkgs; [
    gnupg
    curl
    nmap
    inetutils # telnet
    htop
    screen
    vimPlugins.rust-vim
    nix-zsh-completions
    jetbrains-mono
    zsh
    patchelf
    jdk11
    python38Packages.conda
    rustc
    rustfmt
    rustPackages.clippy
    cargo
    cargo-make
    flatbuffers
    bitwarden-cli
  ] ++ lib.optionals stdenv.isDarwin [
    (import ./brew-installer-derivation { inherit stdenv; inherit pkgs; } homeDirectory)
  ] ++ lib.optionals stdenv.isLinux [
    aspell
    aspellDicts.en
    aspellDicts.ca
    firefox
    thunderbird
    vlc
    keepassx
    keepassxc
    texlive.combined.scheme-medium
    libreoffice
    gimp
    yakuake
    gdrive
    flutter
    android-studio
    androidStudioPackages.canary
    jetbrains.idea-community
    jetbrains.pycharm-community
    bitwarden
  ];

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = ''
      export JAVA_HOME="${homeDirectory}/jdk"
      export PATH=$PATH:/usr/local/bin
    '';

    shellAliases = {
      ff = "/Applications/Firefox.app/Contents/MacOS/firefox -P --no-remote&";
    };

    shellGlobalAliases = {
      python-default-shell = "nix-shell $HOME/.config/nixpkgs/python-default-shell.nix";
      nodejs-default-shell = "nix-shell $HOME/.config/nixpkgs/nodejs-default-shell.nix";
      ruby-default-shell = "nix-shell $HOME/.config/nixpkgs/ruby-default-shell.nix";
    };

    initExtraBeforeCompInit = lib.mkIf stdenv.isDarwin ''
      . $HOME/.nix-profile/etc/profile.d/nix.sh
    '';

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "sudo" "docker" "kubectl" ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Hadi";
    userEmail = "hadilashkari@gmail.com";
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-flutter
      vim-flatbuffers
      vim-android
      vim-tmux
      vim-tmux-clipboard
      vim-tmux-focus-events
      rust-vim
      vim-ruby
    ];
    settings = { ignorecase = true; };
    extraConfig = ''
      syntax on
      filetype plugin indent on
      " On pressing tab, insert 2 spaces
      set expandtab
      " Show existing tabl with 2 space width
      set tabstop=2
      set softtabstop=2
      " When indent with '>' use 2 spaces width
      set shiftwidth=2
      inoremap jj <Esc>
      map <F2> :.w !pbcopy<CR><CR>
      map <F3> :r !pbpaste<CR>

      " set clipboard=unnamed
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
    '';
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-flutter
      vim-flatbuffers
      vim-android
      vim-tmux
      vim-tmux-clipboard
      vim-tmux-focus-events
      rust-vim
      vim-ruby
    ];
  };

  home.file = {
    ".screenrc" = {
      text = ''
        defscrollback 5000
      '';
    };

    "jdk".source = "${pkgs.jdk11}";
    "AndroidSdk" = lib.mkIf stdenv.isLinux { 
      source = "${androidComposition.androidsdk}/libexec/android-sdk";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}

