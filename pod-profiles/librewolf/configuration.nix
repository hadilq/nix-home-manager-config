{
  pkgs,
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

  environment.systemPackages = with pkgs; [
    cacert
  ];

  programs = {
    zsh.enable = true;
  };
}
