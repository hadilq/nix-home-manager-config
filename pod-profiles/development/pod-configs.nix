let
  common-pod-configs = import ../modules/common-pod-configs.nix;
  name = "dev-machine";
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
in
{
  inherit (common-pod-configs) system channelsList uname userHome;
  inherit name homeActivation
    nixosConfigurationSource homeManagerConfigurationSource;
}

