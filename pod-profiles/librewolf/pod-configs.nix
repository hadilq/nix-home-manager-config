{
  podName = "librewolf-pod";
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  etcActivation = true;
  homeActivation = true;
}
