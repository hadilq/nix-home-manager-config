{
  languages ? { },
}:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    enable = true;
    languages = languages;
    settings = {
      editor = {
        shell = [
          "zsh"
          "-c"
        ];
        lsp = {
          display-messages = true;
        };
      };
      keys.insert = {
        j = {
          j = "normal_mode";
        };
      };
    };
  };

}
