{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    nerdfonts
  ];

  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "sidebar.verticalTabs" = true;
      "prefers-color-scheme" = "dark";
    };
  };
}

