
{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
in
{
  home.packages = with pkgs; [
    polkit
    xdg-desktop-portal-hyprland
    gtk4
    kitty
    waybar
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      decoration = {
        shadow_offset = "0 5";
        "col.shadow" = "rgba(00000099)";
      };

      "$mod" = "SUPER";

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
    };
  };
}
