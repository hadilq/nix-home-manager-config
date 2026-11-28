-- Apple keyboard: Option sits where Super is on a PC keyboard. Swap
-- Alt and Super so Option is the Omarchy lead key (menu, workspaces)
-- and Command sends Alt (application shortcuts still work).
--
-- default.hypr.input has already set kb_options (compose, and
-- grp:alts_toggle when a non-Latin layout is present). Append the
-- swap so those options are kept. hid_apple swap_opt_cmd is off, so
-- this is the only swap.
local existing = hl.get_config("input.kb_options")
if type(existing) ~= "string" or existing == "" then
  existing = "omarchy:shift_caps_compose"
end
if not existing:find("altwin:swap_alt_win", 1, true) then
  hl.config({
    input = {
      kb_options = existing .. ",altwin:swap_alt_win",
    },
  })
end
