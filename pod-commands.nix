
{ pkgs, localConfig }:
let
  inherit (pkgs) stdenv;
  firefox-commands = [
    (pkgs.writeShellScriptBin "launch-firefox-container" ''
      export DOWNLOAD_DIR=$(mktemp -d /tmp/firefox-download-XXXX)
      XAUTH=$(mktemp -d /tmp/container_xauth-XXXX)/xauth && touch $XAUTH
      xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - >> out 2>&1

      echo "DOWNLOAD_DIR=$DOWNLOAD_DIR"

      podman run -td --rm --volume=''${DOWNLOAD_DIR}:/home/dev/Downloads\
        --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$XAUTH:$XAUTH" -e DISPLAY=$DISPLAY -e XAUTHORITY="$XAUTH"\
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=firefox firefox-machine:latest

      podman exec -it firefox firefox 2>&1 &
    '')

    (pkgs.writeShellScriptBin "stop-firefox-container" ''
      podman stop firefox && podman rm firefox
    '')
  ];

  crawler-commands = [
    (pkgs.writeShellScriptBin "launch-crawler-container" ''
      podman run -td --rm --pod new:crawler-pod  --volume=${localConfig.crawler-dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=crawler-dev dev-machine:latest

      cd ${localConfig.crawler-dir}/container
      source .env
      podman run --pod crawler-pod\
        --volume=$PWD/data:$DB_DATA\
        -e POSTGRES_DB=$DB_NAME -e POSTGRES_USER="$DB_USER"\
        -e POSTGRES_PASSWORD="$DB_PASSWORD"\
        -e PGDATA=$DB_DATA -e DB_PORT=$DB_PORT\
        -e DB_TEST_DATA=$DB_TEST_DATA -e DB_TEST_NAME=$DB_TEST_NAME\
        --name postgresdb -d postgres

      podman exec -it --user root crawler-dev nix-daemon  &>/dev/null &

      podman cp create-tables.sh postgresdb:/root/create-tables.sh
      podman exec -it crawler-dev /root/create-tables.sh 2>&1 &
    '')

    (pkgs.writeShellScriptBin "stop-crawler-container" ''
      podman stop crawler-dev || true
      podman rm crawler-dev || true
      podman stop postgresdb || true
      podman rm postgresdb || true
      podman pod rm crawler-pod || true
    '')
  ];

  tensorflow-commands = [
    (pkgs.writeShellScriptBin "launch-tensorflow-container" ''
      podman run -td --rm --pod new:tensorflow-pod --volume=${localConfig.tensorflow-dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=tensorflow-dev dev-machine:latest

      podman exec -it --user root tensorflow-dev nix-daemon &>/dev/null &

      mkdir -p ${localConfig.tensorflow-dir}/.packages
      mkdir -p ${localConfig.tensorflow-dir}/.bazelcache

      podman run -td --rm --pod tensorflow-pod --name=tf-sig -w /tf/tensorflow -d \
        --env TF_PYTHON_VERSION=3.9 \
        -v "${localConfig.tensorflow-dir}/.packages:/tf/pkg" \
        -v "${localConfig.tensorflow-dir}:/tf/tensorflow" \
        -v "${localConfig.tensorflow-dir}/.bazelcache:/tf/cache" \
        tf-sig-devel
    '')

    (pkgs.writeShellScriptBin "stop-tensorflow-container" ''
      podman stop tensorflow-dev || true
      podman rm tensorflow-dev || true
      podman stop tf-sig || true
      podman rm tf-sig || true
      podman pod rm tensorflow-pod || true
    '')
  ];

  mkIdeaDevContainerCommands = dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-idea-container" ''
      XAUTH=$(mktemp -d /tmp/container_xauth-XXXX)/xauth && touch $XAUTH
      xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - >> out 2>&1

      podman run -td --rm --volume=${dir}:/home/dev/src\
        --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$XAUTH:$XAUTH" -e DISPLAY=$DISPLAY -e XAUTHORITY="$XAUTH"\
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name}-idea-dev dev-machine:latest

      podman exec -it --user root ${name}-idea-dev nix-daemon &>/dev/null &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-idea-container" ''
      podman stop ${name}-idea-dev || true
      podman rm ${name}-idea-dev || true
    '')
  ];

  mkDevContainerCommands = dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      podman run -td --rm --volume=${dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name}-dev dev-machine:latest

      podman exec -it --user root ${name}-dev nix-daemon &>/dev/null &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-container" ''
      podman stop ${name}-dev || true
      podman rm ${name}-dev || true
    '')
  ];
in
{
  commands = firefox-commands  ++ crawler-commands ++ tensorflow-commands
  ++ (mkDevContainerCommands localConfig.ml-dir "ml")
  ++ (mkDevContainerCommands localConfig.cv-dir "cv")
  ++ (mkDevContainerCommands localConfig.lightening-dir "lightening")
  ++ (mkDevContainerCommands localConfig.zig-metaphor-dir "zm")
  ++ (mkIdeaDevContainerCommands localConfig.hair-colorization-dir "hc");
}
