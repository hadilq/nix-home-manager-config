{ config, pkgs, lib, localConfig, ... }:
let
  inherit (pkgs) stdenv;
in
{
  home.packages = with pkgs; [
    xdg-desktop-portal-hyprland
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle

    light
    pamixer
    kitty
    mako
    #wl-clipboard-rs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      "monitor" = ",1920x1080@60,auto,1";
      "$term" = "kitty";
      #"$menu" = "fuzzel";
      exec-once = [
        "waybar"
        "kitty"
        "firefox -P --no-remote"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      decoration = {
        shadow_offset = "0 5";
        "col.shadow" = "rgba(00000099)";
      };

      general = {
        gaps_in = 5;
        gaps_out = 5;
      };


      bind = [

        "$mod, G, fullscreen,"
        "$mod, K, exec, kitty"
        "$mod, O, exec, firefox -P --no-remote"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, F, exec, nautilus"
        "$mod, V, togglefloating,"
        "$mod, SPACE, exec, wofi --show drun"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, C, exec, console"

        # mouse movements
        #"$mod, mouse:272, movewindow"
        #"$mod, mouse:273, resizewindow"

        # Functional keybinds
        ",XF86AudioMicMute,exec,pamixer --default-source -t"
        ",XF86MonBrightnessDown,exec,light -U 20"
        ",XF86MonBrightnessUp,exec,light -A 20"
        ",XF86AudioMute,exec,pamixer -t"
        ",XF86AudioLowerVolume,exec,pamixer -d 10"
        ",XF86AudioRaiseVolume,exec,pamixer -i 10"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPause,exec,playerctl play-pause"

        # to switch between windows in a floating workspace
        "SUPER,Tab,cyclenext,"
        "SUPER,Tab,bringactivetotop,"

        # Move focus with mainMod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mod SHIFT, 0, movetoworkspace, 10"
      ] ++ (lib.flatten
        (map (n:
          let
            number = toString n;
          in
          [
            "$mod, ${number}, workspace, ${number}"
            "$mod SHIFT, ${number}, movetoworkspace, ${number}"
          ]
        ) (lib.range 1 9)
      ));

      input = {
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
        };
        repeat_rate = 50;
        repeat_delay = 110;
        sensitivity = 0.8;
      };
    };
  };

  programs.waybar.enable = true;
  programs.wofi.enable = true;

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        "DP-1,${localConfig.homeDirectory}/Pictures/nix-wallpaper-simple-blue.png"
      ];
    };
  };
}
