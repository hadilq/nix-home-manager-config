{
}:
{ lib, localConfig, ... }:
let
  homeDirectory = localConfig.homeDirectory;
in
{
  sops = {
    defaultSopsFile = ../../secrets/local.yaml;
    gnupg.home = "/Users/${localConfig.userName}/.gnupg";
    gnupg.sshKeyPaths = [];
    age.sshKeyPaths = lib.mkForce [];

    secrets."add secret file!" = {
      owner = localConfig.userName;
      group = "staff";
      path = "";
      mode = "0600";
    }
  };
}
