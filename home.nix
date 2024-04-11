{ config, pkgs, lib, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  mkUint32 = lib.hm.gvariant.mkUint32;
  localConfig = import ./.local/config.nix { };
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
    gnome.gnome-tweaks
    gnome-extensions-cli
    gnomeExtensions.pop-shell
    gnomeExtensions.pano
    gnomeExtensions.simple-timer
    gsound
    libgda6
  ];

  fonts.fontconfig.enable = true;

  dconf.settings = lib.optionalAttrs stdenv.isLinux {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        "pano@elhan.io"
        "simple-timer@majortomvr.github.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 8;
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell" = {
      last-selected-power-profile = "performance";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.56060606060606055;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      edge-scrolling-enabled = false;
      natural-scroll = true;
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ir" ]) ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      move-to-workspace-right = [ "<Shift><Control><Super>Right" ];
      move-to-workspace-left = [ "<Shift><Control><Super>Left" ];
      switch-to-workspace-right = [ "<Control><Super>Right" ];
      switch-to-workspace-left = [ "<Control><Super>Left" ];
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 110;
      repeat-interval = mkUint32 50;
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 100;
      play-audio-on-copy = false;
    };
  };

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

