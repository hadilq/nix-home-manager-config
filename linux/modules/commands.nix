{ pkgs, localConfig, ... }:
let
  inherit (pkgs) lib;
  inherit (localConfig) local-projects;
  browser-commands = name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      export DOWNLOAD_DIR=$(mktemp -d /tmp/${name}-download-XXXX)
      echo "DOWNLOAD_DIR=$DOWNLOAD_DIR"

      podman run -td --rm --volume=''${DOWNLOAD_DIR}:/home/dev/Downloads\
        --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ -e DISPLAY=$DISPLAY\
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name} ${name}-machine:latest

      podman exec -it ${name} ${name} 2>&1 &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-container" ''
      podman stop ${name} && podman rm ${name}
    '')
  ];

  crawler-commands = [
    (pkgs.writeShellScriptBin "launch-crawler-container" ''
      podman run -td --rm --pod new:crawler-pod  --volume=${local-projects.crawler-dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=crawler-dev dev-machine:latest

      cd ${local-projects.crawler-dir}/container
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
      podman run -td --rm --pod new:tensorflow-pod --volume=${local-projects.tensorflow-dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=tensorflow-dev dev-machine:latest

      podman exec -it --user root tensorflow-dev nix-daemon &>/dev/null &

      mkdir -p ${local-projects.tensorflow-dir}/.packages
      mkdir -p ${local-projects.tensorflow-dir}/.bazelcache

      podman run -td --rm --pod tensorflow-pod --name=tf-sig -w /tf/tensorflow -d \
        --env TF_PYTHON_VERSION=3.9 \
        -v "${local-projects.tensorflow-dir}/.packages:/tf/pkg" \
        -v "${local-projects.tensorflow-dir}:/tf/tensorflow" \
        -v "${local-projects.tensorflow-dir}/.bazelcache:/tf/cache" \
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

  mkXDevContainerCommands = dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''

      podman run -td --rm --volume=${dir}:/home/dev/src\
        --volume=/tmp/.X11-unix/:/tmp/.X11-unix/ -e DISPLAY=$DISPLAY \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name}-dev dev-machine:latest

      podman exec -it --user root ${name}-dev nix-daemon &>/dev/null &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-container" ''
      podman stop ${name}-dev || true
      podman rm ${name}-dev || true
    '')
  ];

  mkDevPortsContainerCommands = ports: dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      podman run -td --volume=${dir}:/home/dev/src \
        ${
          lib.strings.concatStrings (lib.map (p: " -p ${builtins.toString p}:${builtins.toString p}") ports)
        } --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name}-dev dev-machine:latest

      podman exec -it --user root ${name}-dev nix-daemon &>/dev/null &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-container" ''
      podman stop ${name}-dev || true
      podman rm ${name}-dev || true
    '')
  ];

  mkDevContainerCommands = dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      podman run -td --volume=${dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --name=${name}-dev dev-machine:latest

      podman exec -it --user root ${name}-dev nix-daemon &>/dev/null &
    '')

    (pkgs.writeShellScriptBin "stop-${name}-container" ''
      podman stop ${name}-dev || true
      podman rm ${name}-dev || true
    '')
  ];

  checkDir =
    name: commands-fn:
    (lib.optionals (builtins.hasAttr "${name}-dir" local-projects) (
      commands-fn local-projects.${"${name}-dir"} name
    ));
in
{
  home.packages =
    [ ]
    ++ (browser-commands "firefox")
    ++ (browser-commands "librewolf")
    ++ (lib.optionals (builtins.hasAttr "crawler-dir" local-projects) crawler-commands)
    ++ (lib.optionals (builtins.hasAttr "tensorflow-dir" local-projects) tensorflow-commands)
    ++ (checkDir "ml" mkDevContainerCommands)
    ++ (checkDir "cv" (mkDevPortsContainerCommands [ 1111 ]))
    ++ (checkDir "trustycity" mkDevContainerCommands)
    ++ (checkDir "einstein" mkDevContainerCommands)
    ++ (checkDir "tmp-android" mkXDevContainerCommands)
    ++ (checkDir "clipboard-manager" mkDevContainerCommands)
    ++ (checkDir "had-on" mkDevContainerCommands);
}
