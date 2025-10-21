let
  system = "x86_64-linux";
  channelsList = [
    {
      name = "nixpkgs";
      url = "https://nixos.org/channels/nixos-25.05-small";
    }
    {
      name = "home-manager";
      url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    }
  ];
  uname = "dev";
  userHome = "/home/dev";
  mountingDir = "${userHome}/src";
in
{
  inherit
    system
    channelsList
    uname
    userHome
    mountingDir
    ;
}
