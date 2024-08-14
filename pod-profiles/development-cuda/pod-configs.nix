let
  common-pod-configs = import ../common/common-pod-configs.nix;
  name = "dev-cuda-machine";
  podProfileDirPath = ./.;
  etcActivation = false;
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  extraSubstituters = [ "https://cuda-maintainers.cachix.org" ];
  extraTrustedPublicKeys = [ "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
in
{
  inherit (common-pod-configs) nixEffectSource pkgsSource homeManagerSource
    system podCommonDirPath channelsList username userHome mountingDir;
  inherit name podProfileDirPath etcActivation homeActivation
    nixosConfigurationSource homeManagerConfigurationSource
    extraSubstituters extraTrustedPublicKeys;
}

