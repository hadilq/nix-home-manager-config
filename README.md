# nix-home-manager-config

This is my configuration of nix package manager in MacOS and NixOS.

## NixOS
Just run
```
cd TO_THE_LOCAL_PATH_OF_THIS_REPO
nix build .#homeConfigurations.hadi.activationPackage && ./result/activate
```

## MacOS
Just run
```
cd TO_THE_LOCAL_PATH_OF_THIS_REPO
nix run nix-darwin -- switch --flake .#hadi
```


## Both NixOS and MacOS
After installing [home-manager](https://github.com/nix-community/home-manager),
clone this repository into `~/.config/nixpkgs`. Next step is creating `.local/config.nix`
file with your username and home directory with a content similar to the following one.

```
{}:
let
  userName = "your user name";
in {
  userName = "hadi";
  gitEmail = "your git email";
  gitName = "your git name";
  gitSigningKey = "your siging key for git";
  homeDirectory =  "/Users/${userName}";
  system = "x86_64-linux"; # or the darwin one accordingly
  local-projects = {
    ml-dir = "/home/hadi/...";
    crawler-dir = "/home/hadi/...";
  };
}
```

Then run `home-manager switch` and done! All the packages/apps are in new machine with the same configuration.

