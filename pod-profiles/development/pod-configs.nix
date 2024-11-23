let
  common-pod-configs = import ../common/common-pod-configs.nix;
  name = "dev-machine";
  podProfileDirPath = ./.;
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
in
{
  inherit (common-pod-configs) nixEffectSource pkgsSource homeManagerSource
    system podCommonDirPath channelsList uname userHome;
  inherit name podProfileDirPath homeActivation
    nixosConfigurationSource homeManagerConfigurationSource;
}

