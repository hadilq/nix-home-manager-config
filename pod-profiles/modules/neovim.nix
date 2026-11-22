{
  extra-lua-config-files ? [ ],
  extra-plugins ? [ ],
  extra-treesitter-plugins ? p: [ ],
}:
{
  pkgs,
  lib,
  ...
}:
let
  luaDir = ./neovim;
  readLua = rel: builtins.readFile (luaDir + "/${rel}");
  # Order matters: leader in options.lua must run before any <leader> maps.
  initFiles = [
    "options.lua"
    "theme.lua"
    "plugins/treesitter.lua"
    "plugins/cmp.lua"
    "lsp.lua"
    "plugins/telescope.lua"
    "plugins/fff.lua"
    "plugins/fugitive.lua"
    "plugins/undotree.lua"
    "plugins/trouble.lua"
    "keymaps.lua"
  ];
  extraLua = lib.concatMapStringsSep "\n" lib.strings.fileContents extra-lua-config-files;
in
{
  # Nix-only Neovim: every plugin, grammar, LSP server and tool comes from
  # nixpkgs via home-manager's programs.neovim. Nothing is fetched at runtime.
  # extra-lua-config-files / extra-plugins / extra-treesitter-plugins are
  # appended so darwin and the development pods can extend this module.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # home.stateVersion is 23.11, which still implies the old defaults.
    # Adopt the current lean ones: no Ruby or Python provider.
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [
      nixd
      lua-language-server
    ];
    plugins =
      with pkgs.vimPlugins;
      [
        plenary-nvim
        nvim-web-devicons
        tokyonight-nvim
        catppuccin-nvim
        rose-pine
        kanagawa-nvim
        nord-nvim
        everforest
        gruvbox-nvim
        telescope-nvim
        telescope-fzy-native-nvim
        fff-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        luasnip
        cmp_luasnip
        nvim-lspconfig
        (nvim-treesitter.withPlugins (
          p:
          [
            p.bash
            p.c
            p.cpp
            p.css
            p.html
            p.javascript
            p.json
            p.lua
            p.markdown
            p.markdown_inline
            p.nix
            p.python
            p.query
            p.rust
            p.toml
            p.tsx
            p.typescript
            p.vim
            p.vimdoc
            p.yaml
          ]
          ++ extra-treesitter-plugins p
        ))
        vim-fugitive
        undotree
        trouble-nvim
      ]
      ++ extra-plugins;
    initLua =
      (lib.concatMapStringsSep "\n" (f: "-- ${f}\n${readLua f}") initFiles)
      + lib.optionalString (extraLua != "") "\n-- extra-lua-config-files\n${extraLua}";
  };
}
