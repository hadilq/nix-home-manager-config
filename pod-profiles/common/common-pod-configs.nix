let
  system =  "x86_64-linux";
  #nixEffectSource = builtins.fetchTarball "https://github.com/hadilq/nix-effect-pod/archive/57b244c6dca8457f5f5d2f6b060092895066bc65.tar.gz";
  nixEffectSource = builtins.fetchGit  {
  #  url = "file://PATH TO YOUR LOCAL CLONE OF nix-effect-pod";
  #
    url = "file:///home/hadi/dev/nix-effect-pod";
  # rev = "acda3601039382d90de8d83dc4561c339b475c7c";
  };
  # nixos-24.11
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/057f63b6dc1a2c67301286152eb5af20747a9cb4.tar.gz";
  # release-24.11
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/5056a1cf0ce7c2a08ab50713b6c4af77975f6111.tar.gz";
  podCommonDirPath = ./.;
  channelsList = [
    { name = "nixpkgs"; url= "https://nixos.org/channels/nixos-24.11-small"; }
    { name = "home-manager"; url= "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz"; }
  ];
  uname = "dev";
  userHome = "/home/dev";
  mountingDir = "${userHome}/src";
in
{
  inherit system nixEffectSource pkgsSource homeManagerSource
    podCommonDirPath channelsList
    uname userHome mountingDir;
}

