{
  config,
  pkgs,
  lib,
  ...
}: {

  home.packages = with pkgs; [
    gradle
    jdk17
    jdk11
    android-studio
  ];
}

