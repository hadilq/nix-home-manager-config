
{ pkgs, localConfig }:
let
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

  mkDevCudaContainerCommands = dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      podman run -td --rm --volume=${dir}:/home/dev/src \
        --user $(id -u):$(id -g) --userns keep-id:uid=$(id -u),gid=$(id -g)\
        --gpus all \
        --name=${name}-dev dev-cuda-machine:latest

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
in
{
  commands = crawler-commands ++ tensorflow-commands
  ++ (browser-commands "firefox") ++ (browser-commands "librewolf")
  ++ (mkDevContainerCommands localConfig.ml-dir "ml")
  ++ (mkDevContainerCommands localConfig.cv-dir "cv")
  ++ (mkDevCudaContainerCommands localConfig.lightening-dir "lightening")
  ++ (mkDevContainerCommands localConfig.zig-metaphor-dir "zm")
  ++ (mkXDevContainerCommands localConfig.hair-colorization-dir "hc")
  ++ (mkXDevContainerCommands localConfig.note-dir "note")
  ++ (mkDevContainerCommands localConfig.opea-dir "opea")
  ++ (mkXDevContainerCommands localConfig.trustycity-dir "trustycity")
  ++ (mkDevCudaContainerCommands localConfig.health-data-nexus-dir "health-data-nexus")
  ++ (mkDevContainerCommands localConfig.einstein-dir "einstein")
  ++ (mkXDevContainerCommands localConfig.tmp-android-dir "tmp-android")
  ++ (mkDevContainerCommands localConfig.clipboard-manager-dir "clipboard-manager")
  ++ (mkDevContainerCommands localConfig.limbo-dir "limbo")
  ++ (mkDevContainerCommands localConfig.had-on-dir "had-on")
  ++ (mkDevContainerCommands localConfig.spllog-dir "spllog")
  ++ (mkDevContainerCommands localConfig.ollama-dir "ollama")
  ++ (mkXDevContainerCommands localConfig.stable-diffusion-dir "stable-diffusion")
  ++ (mkXDevContainerCommands localConfig.minimalitics-dir "minimalitics")
  ++ (mkXDevContainerCommands localConfig.bevy-wasm-gallery-dir "bevy-wasm-gallery")
  ++ (mkXDevContainerCommands localConfig.iced-wasm-gallery-dir "iced-wasm-gallery")
  ++ (mkDevContainerCommands localConfig.aitinker-dir "aitinker");
}
