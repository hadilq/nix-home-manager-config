let
  system =  "x86_64-linux";
  nixEffectSource = builtins.fetchTarball "https://github.com/hadilq/nix-effect-pod/archive/957e0c053f11dddf381cda7d14503f07b55f5d8e.tar.gz";
  # release-23.11
  pkgsSource = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/d7329da4b1cd24f4383455071346f4f81b7becba.tar.gz";
  # release-23.11
  homeManagerSource = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/d6bb9f934f2870e5cbc5b94c79e9db22246141ff.tar.gz";
  podCommonDirPath = ./.;
  channelsList = [
    { name = "nixpkgs"; url= "https://nixos.org/channels/nixos-23.11-small"; }
    { name = "home-manager"; url= "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz"; }
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

