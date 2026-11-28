# User Hyprland overrides only. Never link over Omarchy-seeded names
# (input.lua, bindings.lua, hyprland.lua, looknfeel.lua, monitors.lua,
# autostart.lua, xdph.conf, hyprsunset.conf, .luarc.json).
#
# The Omarchy session starts Hyprland with --config on the *store*
# hyprland.lua, which already optionally requires hypr.layouts (a file
# Omarchy never seeds). That hook loads after hypr.input, so these
# overrides win. nixarchySeed uses `cp --update=none` and does not
# ship layouts.lua or hypr/user/, so it will not collide with the
# home-manager symlinks (which linkGeneration creates first).
{ lib, config, ... }:
let
  toConfigFile = rel: {
    name = "hypr/${rel}";
    value = {
      source = ./hypr/${rel};
    };
  };
  files = [
    "layouts.lua"
    "user/input.lua"
    "user/brightness.lua"
  ]
  ++ lib.optionals config.my.hypr.swapAltWin [
    "user/keyboard.lua"
  ];
in
{
  options.my.hypr.swapAltWin = lib.mkEnableOption ''
    Swap Alt and Super at the XKB level (`altwin:swap_alt_win`).
    On an Apple keyboard this makes Option the Omarchy lead key
    (the same physical place as Super on a PC keyboard) and Command
    send Alt, so application Alt shortcuts still work. Only enable
    this on hosts with that keyboard layout; leave it off elsewhere.
  '';

  config = {
    xdg.configFile = lib.listToAttrs (map toConfigFile files);
  };
}
