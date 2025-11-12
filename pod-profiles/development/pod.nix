{
  system,
  nixEffectSource,
  pkgsSource,
  homeManagerSource,
}:
let
  pod-configs = import ./pod-configs.nix;
  image = (
    import "${nixEffectSource}/pod.nix" {
      inherit (pod-configs)
        name
        nixosConfigurationSource
        channelsList
        uname
        userHome
        homeActivation
        ;
      inherit system nixEffectSource pkgsSource homeManagerSource;
    }
  );
in
image
