# Desktop apps previously enabled via programs.nixarchy.apps.* on NixOS.
# Those options live only on the NixOS module; the home-manager module
# reads osConfig and does not expose the same apps set in standalone HM.
# Install them here as user packages instead.
#
# Firefox uses programs.firefox so Nix-managed update policies can stay,
# without declaring profiles (that would write profiles.ini). Foot and
# Alacritty are package-only: programs.foot / programs.alacritty would
# write foot.ini / alacritty.toml and clobber Omarchy's seeded files
# (and the font-size activation that edits those regular files).
{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
let
  # Flake `pkgs` is imported without allowUnfree; this predicate is only
  # for the official xAI CLI. Community grok-cli must not stay on PATH:
  # Omarchy launches `grok --permission-mode bypassPermissions`.
  grokBuildPkgs = import pkgs.path {
    inherit (pkgs) system;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "grok-build" ];
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    # Keep the existing profile dir; stateVersion < 26.05 still defaults
    # here, but pin it so a later bump cannot silently relocate it.
    configPath = ".mozilla/firefox";
    policies.DisableAppUpdate = true;
  };

  home.packages = with pkgs; [
    foot
    alacritty
    # Official xAI CLI. hiPrio wins if nixarchy's defaultAgent mapping
    # still adds community pkgs.grok-cli (`grok = pkgs.grok-cli`).
    (lib.hiPrio grokBuildPkgs.grok-build)
  ];
}
