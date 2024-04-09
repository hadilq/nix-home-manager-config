# Pod for development
The code in this directory can create a pod(docker or podman) image and integrate Nixos,
and home-manager, into it. The way I use it is explained below.

# Usage
Run

```shell
$ nix-build pod.nix &&\
  podman load < result
```

To build the image. Befor launching the container you need to authorize podman to use display.
So you have to run

```shell
$ xhost +local:podman
```

To launch the container use the following:

```shell
$ export DOWNLOAD_DIR=$(mktemp -d /tmp/firefox-download-XXXX)
$ podman run -td --rm --volume=${DOWNLOAD_DIR}:/home/dev/Download\
  --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ -e DISPLAY=$DISPLAY\
  --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
  --name=firefox-pod firefox-machine:latest
```

To launch the firefox run

```shell
$ tmux neww podman exec -it firefox-pod firefox
```

Now you have an isolated firefox!
If you don't use `tmux` just remove `tmux neww` and you are good to go.

Don't forget to stop and possibly remove the container.
```shell
$ podman stop firefox-pod
```

Enjoy!

