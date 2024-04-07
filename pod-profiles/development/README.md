# Pod for development
The code in this directory can create a pod(docker or podman) image and integrate Nixos,
and home-manager, into it. The way I use it is explained below.

# Usage
Run

```shell
$ nix-build pod.nix &&\
  podman load < result
```

To build the image. To launch the container use the following:

```shell
$ podman run -td --rm --volume=${PWD}:/home/dev/src \
  --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
  --name=dev-pod dev-machine:latest
```

I prefer to have my development environemtn in tmux so I usually run

```shell
$ tmux neww podman exec -it dev-pod zsh
```

if you don't want tmux, you just only remove the `tmux neww` part.

Now you have my configuration for Tmux, Neovim, etc. So let's develop!
But if you are interested on other configurations, which has a high chance,
then go ahead and edit the `configurations.nix` and `home.nix` files.
The good thing about them is that they are ordinary Nixos, and home-manager, configuration files.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop dev-pod
```

enjoy!

