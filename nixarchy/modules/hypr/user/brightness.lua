-- Display brightness keys. Omarchy's defaults bind these to a shell
-- global shortcut (omarchy:brightness.raise / .lower). Rebind to
-- omarchy-brightness-display so the same command as the Shift/Alt
-- variants is used, and the override lives with the other user hypr
-- hooks. Seeded bindings.lua is not modified.
o.rebind(
  "XF86MonBrightnessUp",
  "Brightness up",
  "omarchy-brightness-display +5%",
  { locked = true, repeating = true }
)
o.rebind(
  "XF86MonBrightnessDown",
  "Brightness down",
  "omarchy-brightness-display 5%-",
  { locked = true, repeating = true }
)
