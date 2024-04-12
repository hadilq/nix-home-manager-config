# Pod for development
The code in this directory can create a container(Docker or Podman) image and integrate NixOS,
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
  --name=dev dev-machine:latest
```

I prefer to have my development environment in tmux, so I usually run

```shell
$ tmux neww podman exec -it dev zsh
```

If you don't want tmux, you only need to remove the `tmux neww` part.
Even though the `endpoint.sh` script runs the `nix-daemon --daemon` command,
but it's not getting launched! I'll try to fix it in the future,
but for now just run it in the root shell like

```shell
$ tmux neww podman exec -it -ueer root dev zsh
```

Now you have my configuration for Tmux, Neovim, etc. So let's develop!
But if you are interested on other configurations, which has a high chance,
then go ahead and edit the `configurations.nix` and `home.nix` files.
The good thing about them is that they are ordinary NixOS, and home-manager, configuration files.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop dev
```

enjoy!

