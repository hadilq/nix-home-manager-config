{
  config,
  pkgs,
  lib,
  localConfig,
  ...
}:
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.jujutsu = {
    enable = true;
    ediff = true;
    settings = {
      user = {
        email = localConfig.gitEmail;
        name = localConfig.gitName;
      };
      ui = {
        editor = "vim";
      };
    };
  };
}
