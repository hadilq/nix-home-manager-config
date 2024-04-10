let
  common-pod-configs = import ../common/common-pod-configs.nix;
  name = "firefox-machine";
  podProfileDirPath = ./.;
  etcActivation = true;
  homeActivation = true;
in
{
  inherit (common-pod-configs) nixEffectSource pkgsSource homeManagerSource nixosConfigurationSource
    system podCommonDirPath
    homeManagerConfigurationSource channelsList
    username userHome mountingDir;
  inherit name podProfileDirPath etcActivation homeActivation;
}

