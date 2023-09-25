{ config, pkgs, lib, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  localConfig = import ./.local/config.nix { };
  userName = localConfig.userName;
  homeDirectory = localConfig.homeDirectory;
  inherit (pkgs) stdenv;
in
{
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
    screen
    nix-zsh-completions
    zsh
    patchelf
    bitwarden-cli
    font-awesome
    font-awesome_4
    nerdfonts
    kotlin-language-server
    jdt-language-server # java language server
    rust-analyzer # rust language server
    rnix-lsp # nix language server
    cmake-language-server
    yaml-language-server
    texlab # latex language server
    ltex-ls # markdown language server
    taplo-lsp # toml lanugae server
    solargraph # ruby language server
  ] ++ (with xorg; [
    fontbh75dpi
    fontbh100dpi
    fonttosfnt
    fontalias
    fontbhttf
    fontsunmisc
    fontbhtype1
  ]) ++ lib.optionals stdenv.isDarwin [
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
    python311Packages.python-lsp-server
    nodePackages.bash-language-server
    neovim-qt
    gnome.gnome-tweaks
    gnome-extensions-cli
    gnomeExtensions.pop-shell
    gnomeExtensions.clipboard-indicator
  ];

  fonts.fontconfig.enable = true;

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = lib.optionalAttrs stdenv.isLinux {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
    defaultCacheTtl = 2592000;
    defaultCacheTtlSsh = 2592000;
    maxCacheTtl = 2592000;
  };

  dconf.settings = lib.optionalAttrs stdenv.isLinux {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "clipboard-indicator@tudmotu.com"
        "pop-shell@system76.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
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
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/fold-l.webp";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/fold-d.webp";
      primary-color = "#26a269";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/fold-d.webp";
      primary-color = "#26a269";
      secondary-color = "#000000";
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      history-size = 100;
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = lib.mkIf stdenv.isDarwin ''
      export PATH=$PATH:/usr/local/bin
    '';

    shellAliases = {
      ff = "/Applications/Firefox.app/Contents/MacOS/firefox -P --no-remote&";
    };

    shellGlobalAliases = {
      python-default-shell = "nix-shell $HOME/.config/nixpkgs/python-default-shell.nix";
      nodejs-default-shell = "nix-shell $HOME/.config/nixpkgs/nodejs-default-shell.nix";
      ruby-default-shell = "nix-shell $HOME/.config/nixpkgs/ruby-default-shell.nix";
      jupyter-default-shell = "nix-shell $HOME/.config/nixpkgs/jupyter-default-shell.nix";
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
    extraConfig = {
      core = {
        editor = "hx";
      };
    };

    includes = [{
      contents = {
        init.defaultBranch = "main";
        user = {
          email = "hadilq.dev@gmail.com";
          name = "Hadi";
          signingKey = "416AD9E8E372C075";
        };
        commit = {
          gpgSign = true;
        };
      };
    }];
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
      set-option -g history-limit 20000
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
    '';
  };

  programs.neovim = {
    enable = true;
    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./neovim/nvim-config.vim)
      ''
        lua << EOF
        ${lib.strings.fileContents ./neovim/nvim-config.lua}
        ${lib.strings.fileContents ./neovim/nvim-lsp.lua}
        EOF
      ''
    ];

    plugins = with pkgs.vimPlugins; [
      vim-flutter
      vim-flatbuffers
      vim-android
      rust-vim
      vim-ruby
      vim-devicons
      vim-snippets
      nerdtree
      vim-startify
      nvim-lspconfig
      lsp-format-nvim
      (nvim-treesitter.withPlugins (p: [
        p.javascript
        p.json
        p.vim
        p.nix
        p.html
        p.yaml
        p.dockerfile
        p.java
        p.kotlin
        p.rust
        p.kotlin
        p.ruby
        p.python
      ]))
    ];
  };

  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "rust";
        }
        {
          name = "nix";
        }
        {
          name = "latex";
        }
        {
          name = "bash";
        }
        {
          name = "markdown";
          language-server = { command = "ltex-ls"; };
        }
        {
          name = "toml";
        }
        {
          name = "kotlin";
        }
        {
          name = "java";
          file-types = [ "java" "gradle" ];
          language-server = { command = "jdt-language-server"; };
        }
        {
          name = "python";
          language-server = { command = "python-lsp-server"; };
        }
      ];
    };
    settings = {
      editor = {
        shell = [ "zsh" "-c" ];
        lsp = {
          display-messages = true;
        };
      };
      keys.insert = {
        j = { j = "normal_mode"; };
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      scroll_buffer_size = 20000;
      scrollback_editor = "hx";
      copy_command = if stdenv.isDarwin then "pbcopy" else "xclip -selection clipboard";
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

