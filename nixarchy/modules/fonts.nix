# User font-size overrides. Seeded Omarchy files (foot.ini, alacritty.toml,
# kitty.conf, ghostty config, looknfeel.lua) are not replaced.
#
# The official hook for the Omarchy shell (bar, launcher, notifications)
# is ~/.config/omarchy/shell.toml, merged on top of the active theme and
# never seeded. GTK uses the same text-scaling-factor that
# `omarchy display text size` writes. Terminals have no drop-in that can
# change only the size without pinning the family, so an activation
# step after nixarchySeed edits :size=/size= in the existing regular
# files — the same approach as that tool — and skips HM store symlinks.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./fonts-size.nix)
    textSize
    terminalPt
    gtkTextScalingFactor
    ;
  sed = "${pkgs.gnused}/bin/sed";
  cfgHome = config.xdg.configHome;
in
{
  xdg.configFile."omarchy/shell.toml".text = ''
    [font]
    base-size = ${toString textSize}
  '';

  xdg.configFile."hypr/user/fonts.lua".text = ''
    -- Groupbar title size. Loaded via hypr/layouts.lua after Omarchy defaults.
    hl.config({
      group = {
        groupbar = {
          font_size = ${toString textSize},
        },
      },
    })
  '';

  dconf.settings."org/gnome/desktop/interface".text-scaling-factor = gtkTextScalingFactor;

  home.activation.omarchyTerminalFontSize = lib.hm.dag.entryAfter [ "nixarchySeed" ] ''
    pt=${toString terminalPt}
    _set_term_size() {
      local f="$1"
      local kind="$2"
      [ -e "$f" ] || return 0
      if [ -L "$f" ]; then
        case "$(readlink -f "$f" 2>/dev/null)" in
          /nix/store/*)
            echo "omarchy terminal font: skipping HM-managed $f"
            return 0
            ;;
        esac
      fi
      case "$kind" in
        foot)
          run ${sed} -i -E "s/(:size=)[0-9.]+/\1$pt/" "$f"
          ;;
        alacritty)
          run ${sed} -i -E "s/^size[[:space:]]*=.*/size = $pt/" "$f"
          ;;
        ghostty)
          run ${sed} -i -E "s/^font-size = .*/font-size = $pt/" "$f"
          ;;
        kitty)
          if grep -qE '^[[:space:]]*font_size[[:space:]]+' "$f"; then
            run ${sed} -i -E "s/^[[:space:]]*font_size[[:space:]]+.*/font_size $pt.0/" "$f"
          else
            if [ -z "''${DRY_RUN:-}" ]; then
              printf '\nfont_size %s.0\n' "$pt" >> "$f"
            else
              echo "would append font_size $pt.0 to $f"
            fi
          fi
          ;;
      esac
    }
    _set_term_size "${cfgHome}/foot/foot.ini" foot
    _set_term_size "${cfgHome}/alacritty/alacritty.toml" alacritty
    _set_term_size "${cfgHome}/ghostty/config" ghostty
    _set_term_size "${cfgHome}/kitty/kitty.conf" kitty
  '';
}
