# nix-home-manager-config

This is my home configuration of nix package manager in MacOS and NixOS.
My NixOS configuration is kept in another repository, [NixOS configuration](https://github.com/hadilq/nixos-configuration).

## Both NixOS and MacOS
First of all fill `.local-config.nix` file, which is a template in this repo.
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

