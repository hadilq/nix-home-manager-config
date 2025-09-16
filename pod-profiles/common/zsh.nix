{ initExtra ? "HISTSIZE=20000" }:
{ lib, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    initExtra = initExtra;

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [ "git" "docker" "kubectl" ];
    };
  };
}
