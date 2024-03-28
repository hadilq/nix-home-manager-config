{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    zsh.enable = true;
    git.enable = true;
  };
}

