
{ pkgs, localConfig }:
let
  inherit (pkgs) stdenv;
  launch-firefox-container = pkgs.writeShellScriptBin "launch-firefox-container" ''
    export DOWNLOAD_DIR=$(mktemp -d /tmp/firefox-download-XXXX)
    XAUTH=$(mktemp -d /tmp/container_xauth-XXXX)/xauth && touch $XAUTH
    xauth nextract - "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - >> out 2>&1

    echo "DOWNLOAD_DIR=$DOWNLOAD_DIR"

    podman run -td --rm --volume=''${DOWNLOAD_DIR}:/home/dev/Downloads\
      --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$XAUTH:$XAUTH" -e DISPLAY=$DISPLAY -e XAUTHORITY="$XAUTH"\
      --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
      --name=firefox firefox-machine:latest

    podman exec -it firefox firefox 2>&1 &
  '';

  stop-firefox-container = pkgs.writeShellScriptBin "stop-firefox-container" ''
    podman stop firefox && podman rm firefox
  '';

  launch-ml-container = pkgs.writeShellScriptBin "launch-ml-container" ''
    podman run -td --rm --volume=${localConfig.ml-dir}:/home/dev/src \
      --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
      --name=ml-dev dev-machine:latest

    podman exec -it --user root ml-dev nix-daemon 2>&1 &
  '';

  stop-ml-container = pkgs.writeShellScriptBin "stop-ml-container" ''
    podman stop ml-dev && podman rm ml-dev
  '';

  launch-crawler-container = pkgs.writeShellScriptBin "launch-crawler-container" ''
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

    podman exec -it --user root crawler-dev nix-daemon 2>&1 &

    podman cp create-tables.sh postgresdb:/root/create-tables.sh
    podman exec -it crawler-dev /root/create-tables.sh 2>&1 &
  '';

  stop-crawler-container = pkgs.writeShellScriptBin "stop-crawler-container" ''
    podman stop crawler-dev || true
    podman rm crawler-dev || true
    podman stop postgresdb || true
    podman rm postgresdb || true
    podman pod rm crawler-pod || true
  '';
in
{
  inherit launch-firefox-container stop-firefox-container
    launch-ml-container stop-ml-container
    launch-crawler-container stop-crawler-container;
}
