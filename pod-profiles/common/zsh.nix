{ initExtra ? "HISTSIZE=10000" }:
{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    initExtra = initExtra;

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" "kubectl" ];
    };
  };
}
