{ config, pkgs, lib, ... }:
{
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "sidebar.verticalTabs" = true;
      "prefers-color-scheme" = "dark";
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "network.cookie.lifetimePolicy" = 0;
    };
  };
}
