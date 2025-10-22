{
  extra-lua-config-files ? [ ],
  extra-plugins ? [ ],
  extra-treesitter-plugins ? p: [ ],
}:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.neovim = {
    enable = true;
    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./neovim/nvim-config.vim)
      ''
        lua << EOF
        ${lib.strings.fileContents ./neovim/nvim-colors.lua}
        ${lib.strings.fileContents ./neovim/nvim-config-primary.lua}
        ${lib.strings.fileContents ./neovim/nvim-fugitive.lua}
        ${lib.strings.fileContents ./neovim/nvim-lsp.lua}
        ${lib.strings.fileContents ./neovim/nvim-lsp-primary-lang-setup.lua}
        ${lib.strings.fileContents ./neovim/nvim-telescope.lua}
        ${lib.strings.fileContents ./neovim/nvim-treesitter.lua}
        ${lib.concatStringsSep "\n" (builtins.map lib.strings.fileContents extra-lua-config-files)}
        EOF
      ''
    ];

    plugins =
      with pkgs.vimPlugins;
      [
        telescope-nvim
        telescope-fzy-native-nvim
        trouble-nvim
        vim-fugitive
        undotree
        rose-pine
        (nvim-treesitter.withPlugins (
          p:
          [
            p.lua
            p.nix
          ]
          ++ (extra-treesitter-plugins p)
        ))
        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        nvim-cmp
      ]
      ++ extra-plugins;
  };

}
