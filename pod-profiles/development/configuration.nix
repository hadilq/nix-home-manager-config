{
  nixEffectSource,
  homeManagerSource,
  ...
}:
let
  pod-configs = import ./pod-configs.nix;
  configuration = import "${nixEffectSource}/configuration.nix" {
    inherit (pod-configs) homeManagerConfigurationSource uname userHome;
    inherit homeManagerSource;
  };
in
{
  imports = [ configuration ];

  programs = {
    zsh.enable = true;
    git.enable = true;
  };
}

