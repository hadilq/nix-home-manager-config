let
  pod-configs = import ./pod-configs.nix;
  image = (import "${pod-configs.nixEffectSource}/pod.nix" {
    inherit (pod-configs) system pkgsSource name nixosConfigurationSource
      channelsList podProfileDirPath podCommonDirPath uname userHome
      etcActivation homeActivation;
  });
in
image
