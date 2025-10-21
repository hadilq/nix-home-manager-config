{
  nixEffectSource,
  pkgsSource,
  homeManagerSource,
}:
let
  pod-configs = import ./pod-configs.nix;
  image = (
    import "${nixEffectSource}/pod.nix" {
      inherit (pod-configs)
        system
        name
        nixosConfigurationSource
        channelsList
        uname
        userHome
        etcActivation
        homeActivation
        ;
      inherit nixEffectSource pkgsSource homeManagerSource;
    }
  );
in
image
