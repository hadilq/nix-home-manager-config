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
$ export UID=$(id -u) && export GID=$(id -g)
$ podman run -td --rm --volume=${PWD}:/home/dev/src \
  --user $UID:$GID --userns keep-id:uid=$UID,gid=$GID dev-machine:latest
```

I prefer to have my development environemtn in tmux so I usually run

```shell
$ podman ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS     NAMES
61d6f161ab76   dev-machine:latest       "/nix/var/nix/profil…"   2 hours ago     Up 2 hours               infallible_hugle

$ tmux neww podman exec -it d077a03af772 zsh
```

if you don't want tmux, you just only remove the `tmux neww` part.

Now you have my configuration for Tmux, Neovim, etc. So let's develop!
But if you are interested on other configurations, which has a high chance,
then go ahead and edit the `configurations.nix` and `home.nix` files.
The good thing about them is that they are ordinary Nixos, and home-manager, configuration files.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop `podman ps -q -l`
```

enjoy!

