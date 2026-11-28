# Make gnome-libsecret (gnome-keyring, Secret Service) the secret store for
# Electron/Chromium apps on every host.
#
# Electron chooses its safeStorage/os_crypt backend from XDG_CURRENT_DESKTOP;
# "Hyprland" is unknown to it, so it silently falls back to basic_text (key
# stored in plain text). Signal records the backend in ~/.config/Signal/
# config.json and refuses to start if it changes (SafeStorageBackendChangeError),
# so the backend must be pinned, not auto-detected.
#
# nixpkgs' Electron wrappers read no *-flags.conf, so the flag is baked into
# the wrapper. Chromium (~/.config/chromium-flags.conf) already carries
# --password-store=gnome-libsecret from Omarchy's own migration. The
# system half (gnome-keyring + PAM unlock) is modules/keyring.nix in the
# nixos-configuration repo.
{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
let
  flag = "--password-store=gnome-libsecret";

  withLibsecret =
    pkg: bin:
    pkgs.symlinkJoin {
      name = "${pkg.name}-libsecret";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${bin} --add-flags ${lib.escapeShellArg flag}
      '';
      inherit (pkg) meta;
    };
in
{
  home.packages = [
    (withLibsecret pkgs-unstable.signal-desktop "signal-desktop")
  ];
}
