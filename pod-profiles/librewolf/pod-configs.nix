let
  common-pod-configs = import ../modules/common-pod-configs.nix;
  name = "librewolf-machine";
  etcActivation = true;
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
in
{
  inherit (common-pod-configs) pkgsSource homeManagerSource
    system channelsList uname userHome;
  inherit name etcActivation homeActivation
    nixosConfigurationSource homeManagerConfigurationSource;
}

