{ config, pkgs, lib, ... }:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      undotree
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
      let mapleader = ","
      nnoremap <leader>u :UndotreeToggle<CR>
    '';
  };
}
