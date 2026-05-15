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

  zsh-nix = import ../pod-profiles/modules/zsh.nix {
    initContent = ''
      EDITOR="vim"
    '';
  };
in
{
  imports = [
    ../modules/home.nix
    neovim-nix
    zsh-nix
  ];

  home.packages = with pkgs; [
    python3
    openssl
    nodejs
    zulu17
    podman
    podman-desktop
    qemu_full
    alacritty
    kotlin-language-server
    jdt-language-server # java
    sourcekit-lsp # swift
    sops
    awscli2
    ssm-session-manager-plugin
    yamlfmt
    glab
    ktlint
    claude-code
    xcodegen
    yq
  ];

  home.file.".ideavimrc" = {
    text = ''
      imap jj <Esc>
      set timeoutlen=500
    '';
  };

}
