# Pod for Jupyter
The code in this directory can create a container(Docker or Podman) image and integrate NixOS,
and home-manager, into it. The way I use it is explained below.

# Usage
Run

```shell
$ nix-build pod.nix &&\
  podman load < result
```

To build the image. Before launching the container you need to authorize Podman to use display.
So you have to run

```shell
$ XAUTH=/tmp/container_xauth
$ xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
```

To launch the container use the following:

```shell
$ podman run -td --rm --volume=${PWD}:/home/dev/src\
  --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$XAUTH:$XAUTH"\
  -e DISPLAY=$DISPLAY -e XAUTHORITY="$XAUTH"\
  --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
  --name=jupyter jupyter-machine:latest
```

To launch the Jupyter run

```shell
$ tmux neww podman exec -it jupyter zsh # Then `jupyter lab` from there
```

Now you have an isolated Jupyter!
If you don't use `tmux` just remove `tmux neww` and you are good to go.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop jupyter
```

Enjoy!

