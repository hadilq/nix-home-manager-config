let
  system =  "x86_64-linux";
  #nixEffectSource = builtins.fetchTarball "https://github.com/hadilq/nix-effect-pod/archive/57b244c6dca8457f5f5d2f6b060092895066bc65.tar.gz";
  nixEffectSource = builtins.fetchGit  {
  #  url = "file://PATH TO YOUR LOCAL CLONE OF nix-effect-pod";
  #
    url = "file:///home/hadi/dev/nix-effect-pod";
  # rev = "acda3601039382d90de8d83dc4561c339b475c7c";
  };
  # nixos-25.05
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/7c43f080a7f28b2774f3b3f43234ca11661bf334.tar.gz";
  # release-25.05
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/d0bbd221482c2713cccb80220f3c9d16a6e20a33.tar.gz";
  podCommonDirPath = ./.;
  channelsList = [
    { name = "nixpkgs"; url= "https://nixos.org/channels/nixos-25.05-small"; }
    { name = "home-manager"; url= "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz"; }
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

