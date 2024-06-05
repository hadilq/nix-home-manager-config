{ config, pkgs, lib, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  mkUint32 = lib.hm.gvariant.mkUint32;
  inherit (pkgs) stdenv;
in
{
  home.packages = with pkgs; lib.optionals stdenv.isLinux ([
    wayland
    gnome.gnome-shell
    gnome.gnome-session
    gnome-photos
    gnome-tour
    xterm
    gnome.gnome-tweaks
    gnome-extensions-cli
    gnomeExtensions.pop-shell
    gnomeExtensions.pano
    gnomeExtensions.simple-timer
  ] ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    yelp # Help view
    gnome-contacts
  ]));

  dconf.settings = lib.optionalAttrs stdenv.isLinux {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        "pano@elhan.io"
        "simple-timer@majortomvr.github.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 8;
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell" = {
      last-selected-power-profile = "performance";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.56060606060606055;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      edge-scrolling-enabled = false;
      natural-scroll = true;
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ir" ]) ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      move-to-workspace-right = [ "<Shift><Control><Super>Right" ];
      move-to-workspace-left = [ "<Shift><Control><Super>Left" ];
      switch-to-workspace-right = [ "<Control><Super>Right" ];
      switch-to-workspace-left = [ "<Control><Super>Left" ];
    };

    "org/gnome/desktop/background" = {
      picture-uri =  "file:///nix/store/dh80m4jdaa19laww3pn699qp2c3yfip0-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      picture-uri-dark =  "file:///nix/store/dh80m4jdaa19laww3pn699qp2c3yfip0-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      primary-color = "#3a4ba0";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri =  "file:///nix/store/dh80m4jdaa19laww3pn699qp2c3yfip0-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      primary-color = "#3a4ba0";
      secondary-color = "#2f302f";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 110;
      repeat-interval = mkUint32 50;
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 100;
      play-audio-on-copy = false;
    };
  };
}
