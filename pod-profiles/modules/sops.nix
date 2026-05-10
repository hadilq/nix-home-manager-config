{
}:
{ localConfig, ... }:
let
  homeDirectory = localConfig.homeDirectory;
in
{
  sops = {
    defaultSopsFile = ../secrets/local.yaml;
    gnupg.home = "/Users/${localConfig.userName}/.gnupg";
    gnupg.sshKeyPaths = [];

    secrets."add secret file!" = {
      owner = "";
      group = "staff";
      path = "";
      mode = "0600";
    }
  };
}
