let
  system =  "x86_64-linux";
  nixEffectSource = builtins.fetchTarball "https://github.com/hadilq/nix-effect-pod/archive/957e0c053f11dddf381cda7d14503f07b55f5d8e.tar.gz";
  # release-24.05
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/805a384895c696f802a9bf5bf4720f37385df547.tar.gz";
  # release-24.05
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/a631666f5ec18271e86a5cde998cba68c33d9ac6.tar.gz";
  podCommonDirPath = ./.;
  channelsList = [
    { name = "nixpkgs"; url= "https://nixos.org/channels/nixos-24.05-small"; }
    { name = "home-manager"; url= "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"; }
  ];
  username = "dev";
  userHome = "/home/dev";
  mountingDir = "${userHome}/src";
  etcActivation = false;
  homeActivation = true;
in
{
  inherit system nixEffectSource pkgsSource homeManagerSource
    podCommonDirPath channelsList
    username userHome mountingDir;
}

