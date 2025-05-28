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
    pinentry.package = pkgs.pinentry-tty;
    defaultCacheTtl = 2592000;
    defaultCacheTtlSsh = 2592000;
    maxCacheTtl = 2592000;
  };

}
