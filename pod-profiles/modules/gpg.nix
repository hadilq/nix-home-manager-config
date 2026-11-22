{ pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
in
{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = lib.optionalAttrs stdenv.isLinux {
    enable = true;
    enableSshSupport = true;
    pinentry.package = if stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-tty;
    # Short passphrase caches: a warm cache lets any process running as this
    # user decrypt or sign silently (secret-broker also refuses to unlock
    # above these limits).
    defaultCacheTtl = 900;
    maxCacheTtl = 7200;
    defaultCacheTtlSsh = 900;
    maxCacheTtlSsh = 7200;
  };
}
