# nix-home-manager-config

This is my home configuration of nix package manager in MacOS and NixOS.
My NixOS configuration is kept in another repository, [NixOS configuration](https://github.com/hadilq/nixos-configuration).

## Both NixOS and MacOS
First of all create `.local/config.nix` file
with your username and home directory with a content similar to the following one.

```
{}:
let
  userName = "hadi";
in {
  inherit userName;
  gitEmail = "your git email";
  gitName = "your git name";
  gitSigningKey = "your siging key for git";
  homeDirectory =  "/Users/${userName}";
  system = "x86_64-linux"; # or aarch64-darwin
  local-projects = {
    ml-dir = "/home/hadi/...";
    crawler-dir = "/home/hadi/...";
  };
}
```

Then run `git add -f .local/config.nix`!
Then run below commands to switch your configuration.

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
nix build .#darwinConfigurations.hadi.config.system.build.toplevel && sudo ./result/activate
```


# Containers
I have some containers in this repository that I use mostly for development and browsing internet
for isolation purposes.
You can build them by running

```
nix build .#pod.development && podman load < result
```

or

```
nix build .#pod.librewolf && podman load < result
```

