# Pod for development
The code in this directory can create a container(via Docker or Podman) image and integrate NixOS,
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
$ XAUTH=$(mktemp -d /tmp/container_xauth-XXXX)/xauth && touch $XAUTH
$ xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
```

To launch the container use the following:

```shell
$ export DOWNLOAD_DIR=$(mktemp -d /tmp/librewolf-download-XXXX)
$ podman run -td --rm --volume=${DOWNLOAD_DIR}:/home/dev/Downloads\
  --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$XAUTH:$XAUTH"\
  -e DISPLAY=$DISPLAY -e XAUTHORITY="$XAUTH"\
  --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
  --name=librewolf librewolf-machine:latest
```

To launch the Librewolf run

```shell
$ tmux neww podman exec -it librewolf librewolf
```

Now you have an isolated Librewolf!
If you don't use `tmux` just remove `tmux neww` and you are good to go.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop librewolf
```

Enjoy!

