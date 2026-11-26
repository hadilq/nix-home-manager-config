# Personal idle/suspend policy, delivered the same way as fonts.nix:
# xdg.configFile."hypr/user/idle.lua".text, loaded from hypr/layouts.lua
# after Omarchy defaults. ~/.config/hypr itself is not edited by hand
# and is otherwise reserved for nixarchy/omarchy seeds.
#
# Omarchy 4.5 has no hypridle. Screensaver (150s) and lock (300s) are
# native shell settings in ~/.config/omarchy/shell.json and cannot be
# set via hl.config; this module leaves them alone. Auto-suspend is not
# a shell.json key, so the user hook implements it in Lua.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.idle;
in
{
  options.my.idle = {
    suspendSeconds = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 20 * 60;
      description = ''
        Seconds of user idle before suspending, on battery only.
        On AC power the timer is reset / ignored so the machine keeps
        working. Set to 0 to disable auto-suspend. Overridable per host
        in linux/darter.nix or linux/macy.nix.
      '';
    };
  };

  config = {
    xdg.configFile."hypr/user/idle.lua".text = ''
      -- Battery-only auto-suspend. Loaded via hypr/layouts.lua after Omarchy defaults.
      -- Screensaver (150s) and lock (300s) stay in ~/.config/omarchy/shell.json.

      local suspend_seconds = ${toString cfg.suspendSeconds}
      local poll_ms = 1000

      local function stay_awake()
        local path = (os.getenv("HOME") or "") .. "/.local/state/omarchy/indicators/stay-awake"
        local file = io.open(path, "r")
        if file then
          file:close()
          return true
        end
        return false
      end

      -- Same check as omarchy-power-present: any Mains/USB supply with online=1.
      local function on_ac()
        return o.shell_succeeds([=[
          for supply in /sys/class/power_supply/*; do
            [ -r "$supply/online" ] && [ -r "$supply/type" ] || continue
            typ=$(cat "$supply/type")
            [ "$typ" = Mains ] || [ "$typ" = USB ] || continue
            [ "$(cat "$supply/online")" = 1 ] && exit 0
          done
          exit 1
        ]=])
      end

      local function idle_inhibited()
        for _, window in ipairs(hl.get_windows() or {}) do
          if window.inhibiting_idle then
            return true
          end
        end
        return false
      end

      local last_cursor = nil
      local function cursor_moved()
        local pos = hl.get_cursor_pos()
        if not pos then
          return false
        end
        local moved = last_cursor and (pos.x ~= last_cursor.x or pos.y ~= last_cursor.y)
        last_cursor = pos
        return moved
      end

      if suspend_seconds == 0 then
        if __user_idle_suspend_timer then
          __user_idle_suspend_timer:set_enabled(false)
          __user_idle_suspend_timer = nil
        end
        return
      end

      local idle_for = 0

      hl.on("input.keyboard.key", function()
        idle_for = 0
      end)

      -- Drop a previous timer if Hyprland reloads this file.
      if __user_idle_suspend_timer then
        __user_idle_suspend_timer:set_enabled(false)
      end

      __user_idle_suspend_timer = hl.timer(function()
        if cursor_moved() or idle_inhibited() or stay_awake() then
          idle_for = 0
          return
        end

        idle_for = idle_for + (poll_ms / 1000)
        if idle_for < suspend_seconds then
          return
        end

        -- Check AC only at the deadline so we don't fork every poll.
        idle_for = 0
        if on_ac() then
          return
        end
        hl.exec_cmd("systemctl suspend")
      end, { timeout = poll_ms, type = "repeat" })
    '';
  };
}
