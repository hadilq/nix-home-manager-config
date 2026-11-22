-- Loaded by Omarchy 4.5 / nixarchy's store hyprland.lua:
--   require("default.hypr.require_optional").module("hypr.layouts")
--
-- This filename is never seeded. It is the official optional hook
-- (nixarchy #1596, documented as layout settings) and the only hook the
-- Omarchy session actually runs: Hyprland is started with --config on the
-- store hyprland.lua, so a require added to ~/.config/hypr/hyprland.lua
-- would not apply.
--
-- This file only loads user overrides from ~/.config/hypr/user/.
require("hypr.user.input")
require("hypr.user.fonts")
require("hypr.user.brightness")
