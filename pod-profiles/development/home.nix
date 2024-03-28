{
  config,
  pkgs,
  lib,
  username,
  ...
}: {

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  home.packages = with pkgs; [
    curl
    ripgrep
    xclip
    zsh
    glab
    gh
    lua-language-server
    kotlin-language-server
    jdt-language-server # java language server
    vscode-langservers-extracted
    rust-analyzer # rust language server
    rustfmt
    zls # zig language server
    nixd # nix language server
    cmake-language-server
    yaml-language-server
    texlab # latex language server
    ltex-ls # markdown language server
    taplo-lsp # toml lanugae server
    solargraph # ruby language server
  ];

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = "HISTSIZE=10000";

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" "kubectl" ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.direnv  = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;

    includes = [{
      contents = {
        init.defaultBranch = "main";
      };
    }];
  };

  programs.neovim = {
    enable = true;
    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./neovim/nvim-config.vim)
      ''
        lua << EOF
        ${lib.strings.fileContents ./neovim/nvim-colors.lua}
        ${lib.strings.fileContents ./neovim/nvim-config.lua}
        ${lib.strings.fileContents ./neovim/nvim-fugitive.lua}
        ${lib.strings.fileContents ./neovim/nvim-lsp.lua}
        ${lib.strings.fileContents ./neovim/nvim-telescope.lua}
        ${lib.strings.fileContents ./neovim/nvim-treesitter.lua}
        ${lib.strings.fileContents ./neovim/nvim-rustaceanvim.lua}
        EOF
      ''
    ];

    plugins = with pkgs.vimPlugins; [
      vim-grammarous
      vim-abolish
      telescope-nvim
      telescope-fzy-native-nvim
      trouble-nvim
      vim-fugitive
      refactoring-nvim
      undotree
      nvim-cmp
      vim-vsnip
      cmp-buffer
      cmp-nvim-lsp
      nvim-lspconfig
      nvim-lint
      conform-nvim
      rose-pine
      rustaceanvim
      lsp-inlayhints-nvim
      (nvim-treesitter.withPlugins (p: [
        p.c
        p.lua
        p.javascript
        p.java
        p.json
        p.vim
        p.nix
        p.html
        p.yaml
        p.dockerfile
        p.java
        p.kotlin
        p.rust
        p.zig
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
          name = "zig";
        }
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
          language-servers = [ "ltex-ls" ];
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
          language-servers = [ "jdt-language-server" ];
        }
        {
          name = "python";
          language-servers = [ "python-lsp-server" ];
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

}

