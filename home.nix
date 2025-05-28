{ config, pkgs, lib, localConfig, pkgs-unstable, ... }:
let
  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;

  pod-commands = import ./pod-commands.nix { inherit pkgs localConfig; };
  zsh-nix = import ./pod-profiles/common/zsh.nix {
    initExtra = lib.mkIf stdenv.isDarwin ''
      export PATH=$PATH:/usr/local/bin
      HISTSIZE=10000
    '';
  };
  neovim-nix = import ./pod-profiles/common/neovim.nix { };
  helix-nix = import ./pod-profiles/common/helix.nix { };
  autostart-nix = import ./autostart.nix;
  cosmic-applets-nix = import ./cosmic/applets.nix;

  inherit (pkgs) stdenv;
in
{
  imports = [
    ./pod-profiles/common/vim.nix
    ./pod-profiles/common/gpg.nix
    ./pod-profiles/common/shell-tools.nix
    ./pod-profiles/common/tmux.nix
    zsh-nix
    neovim-nix
    helix-nix
    autostart-nix
    # cosmic-panel-config is depending on git+https! Waiting for the fix of https://github.com/pop-os/cosmic-panel/blob/1c9c4e2a2cf27efd0ca77b5ec21bc6f7fa92d9da/Cargo.lock#L4239
    #cosmic-applets-nix
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
    #nerd-fonts
    imagemagick
    lua-language-server
    nixd # nix language server
    chromium
    rclone
    pass
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
    gdrive
    bitwarden
    virt-manager
    kdePackages.krfb
    neovim-qt
    inkscape
    pulseaudioFull
    gsound
    libgda6
    wl-clipboard
    pkgs-unstable.signal-desktop
    libsForQt5.okular # remember https://askubuntu.com/questions/54794/cannot-view-pdf-files-with-fillable-fields-with-okular/298942#298942
    speedcrunch
    loupe
    (callPackage ./pod-profiles/common/zen.nix {})
  ] ++ pod-commands.commands;

  fonts.fontconfig.enable = true;
  #fonts.fonts = [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

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
      . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
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

  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "sidebar.verticalTabs" = true;
      "prefers-color-scheme" = "dark";
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "network.cookie.lifetimePolicy" = 0;
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
  home.stateVersion = "23.11";
}

