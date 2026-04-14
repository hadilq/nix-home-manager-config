{
  initContent ? "HISTSIZE=20000",
}:
{ localConfig, ... }:
let
  homeDirectory = localConfig.homeDirectory;
in
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = "${homeDirectory}/.config/zsh";
    initContent = initContent;
    shellAliases = {
      hn = "hostname";
    };

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
