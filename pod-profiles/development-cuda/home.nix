{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  zsh-nix = import ./../common/zsh.nix {
    initContent = ''
      HISTSIZE=10000
      export TERM=screen-256color
      export LANG=en_US.UTF-8
      export LC_CTYPE=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
    '';
  };
  neovim-nix = import ./../common/neovim.nix {
    extra-lua-config-files = [
      ./../common/neovim/nvim-config-development.lua
      ./../common/neovim/nvim-lsp-development-lang-setup.lua
      ./../common/neovim/nvim-rustaceanvim.lua
      ./../common/neovim/nvim-clangd.lua
    ];
    extra-plugins =  with pkgs.vimPlugins; [
      grammar-guard-nvim
      vim-abolish
      refactoring-nvim
      nvim-lint
      rustaceanvim
      clangd_extensions-nvim
    ];
    extra-treesitter-plugins = p: [
        p.c
        p.javascript
        p.java
        p.json
        p.vim
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
      ];
  };

  helix-nix = import ./../common/helix.nix {
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
  };

in
{

  imports = [
    ./../common/vim.nix
    ./../common/shell-tools.nix
    ./../common/tmux.nix
    zsh-nix
    neovim-nix
    helix-nix
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;

  home.packages = with pkgs; [
    curl
    ripgrep
    fd
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
    python312Packages.python-lsp-server
    nodePackages.bash-language-server
    nodePackages.nodejs
    google-java-format
    ktlint
    rubyPackages.prettier
    prettierd
    stylua
    yamlfix
    tree-sitter
    powerline-fonts
    clang-tools # includes clangd
  ];

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;

    includes = [{
      contents = {
        init.defaultBranch = "main";
      };
    }];
  };
}

