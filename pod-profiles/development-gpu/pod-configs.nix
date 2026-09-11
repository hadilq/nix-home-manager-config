let
  uname = "dev";
  homeDirectory = "/home/dev";
in
{
  podName = "dev-gpu-pod";
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  inherit uname;
  userHome = homeDirectory;
  extraSpecialArgs = {
    localConfig = {
      inherit homeDirectory;
      # you should never commit inside the pod!
      gitName = "dev";
      gitEmail = "dev@nix-effect-pod.com";
    };
  };
}
