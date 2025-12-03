{ pkgs, ... }:
let
  neovim-nix = import ../pod-profiles/modules/neovim.nix {
    extra-lua-config-files = [ ];
    extra-treesitter-plugins = p: [
      p.java
      p.json
      p.vim
      p.html
      p.yaml
      p.dockerfile
      p.java
      p.kotlin
      p.swift
      p.kotlin
      p.ruby
      p.python
    ];
  };

in
{
  imports = [
    ../modules/home.nix
    neovim-nix
  ];

  home.packages = with pkgs; [
    python3
    openssl
    nodejs
    zulu17
    podman
    qemu_full
    alacritty
    kotlin-language-server
    jdt-language-server # java
    sourcekit-lsp # swift
  ];
}
