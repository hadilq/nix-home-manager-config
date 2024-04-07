{ config, pkgs, lib, ... }:
{
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
}

