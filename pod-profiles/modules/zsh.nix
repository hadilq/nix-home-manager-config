{
  initContent ? "HISTSIZE=20000",
}:
{ lib, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    initContent = initContent;

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [
        "git"
        "docker"
        "kubectl"
      ];
    };
  };
}
