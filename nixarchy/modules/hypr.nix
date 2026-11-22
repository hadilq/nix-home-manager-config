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
{ lib, ... }:
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
  ];
in
{
  xdg.configFile = lib.listToAttrs (map toConfigFile files);
}
