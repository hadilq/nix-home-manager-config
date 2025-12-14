let
  uname = "dev";
  homeDirectory = "/home/dev";
in
{
  podName = "dev-pod";
  homeActivation = true;
  nixosConfigurationSource = ./configuration.nix;
  homeManagerConfigurationSource = ./home.nix;
  inherit uname;
  userHome = homeDirectory;
  extraSpecialArgs = {
    localConfig = {
      inherit homeDirectory;
    };
  };
}
