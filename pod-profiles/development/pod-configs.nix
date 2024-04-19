let
  common-pod-configs = import ../common/common-pod-configs.nix;
  name = "dev-machine";
  podProfileDirPath = ./.;
  etcActivation = false;
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
in
{
  inherit (common-pod-configs) nixEffectSource pkgsSource homeManagerSource
    system podCommonDirPath channelsList username userHome mountingDir;
  inherit name podProfileDirPath etcActivation homeActivation
    nixosConfigurationSource homeManagerConfigurationSource;
}

