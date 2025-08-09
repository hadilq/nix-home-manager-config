let
  common-pod-configs = import ../common/common-pod-configs.nix;
  name = "firefox-machine";
  podProfileDirPath = ./.;
  etcActivation = true;
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
in
{
  inherit (common-pod-configs) nixEffectSource pkgsSource homeManagerSource
    system podCommonDirPath channelsList uname userHome;
  inherit name podProfileDirPath etcActivation homeActivation
    nixosConfigurationSource homeManagerConfigurationSource;
}

