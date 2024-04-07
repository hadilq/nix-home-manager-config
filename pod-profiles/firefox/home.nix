{
  config,
  pkgs,
  lib,
  ...
}: {

  programs.firefox = {
    enable = true;
    policies = {
      "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
    };

    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        search = {
          force = true;
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Google" ];
        };
        settings = {          # specify profile-specific preferences here; check about:config for options
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.startup.homepage" = "https://nixos.org";
          "browser.newtabpage.pinned" = [{
            title = "NixOS";
            url = "https://nixos.org";
          }];
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

          # For Firefox GNOME theme:
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.drawInTitlebar" = true;
          "svg.context-properties.content.enabled" = true;
          # add preferences for profile_0 here...
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          noscript
          sidebartabs
        ];
      };
      nixos = {
        id = 1;
        name = "nixos";
        isDefault = false;
        settings = {
          "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
          "browser.startup.homepage" = "https://nixos.org";
          "browser.newtabpage.pinned" = [{
            title = "NixOS";
            url = "https://nixos.org";
          }];
        };
      };
      # add profiles here...
    };
    
  };
}

