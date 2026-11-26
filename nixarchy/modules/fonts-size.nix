# Shared formula for apparent text size, in the same units as
# `omarchy display text size` (px). Omarchy's default is 12.
#
# Derived values follow that tool's anchors:
#   12px shell == GTK text-scaling-factor 1.0 == 9pt terminal font.
# 10 is moderately smaller: shell 12->10, terminals 9pt->8pt.
#
# Set `textSize` and `gtkFontPt` per host in linux/darter.nix and
# linux/macy.nix. `gtkFontPt` is the Adwaita Sans point size this
# config uses; the official tool quantizes so the interface font
# lands on a whole point size.
{
  textSize,
  gtkFontPt ? 11,
}:
rec {
  inherit textSize gtkFontPt;

  terminalPt = builtins.floor (textSize * 9.0 / 12 + 0.5);

  gtkTextScalingFactor = (builtins.floor (gtkFontPt * textSize / 12.0 + 0.5)) * 1.0 / gtkFontPt;
}
