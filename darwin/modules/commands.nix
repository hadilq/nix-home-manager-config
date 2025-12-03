{ pkgs, localConfig, ... }:
let
  inherit (pkgs) lib;
  inherit (localConfig) local-projects;

  mkDevPortsContainerCommands = ports: dir: name: [
    (pkgs.writeShellScriptBin "launch-${name}-container" ''
      podman run -td --volume=${dir}:/home/dev/src \
        ${
          lib.strings.concatStrings (lib.map (p: " -p ${builtins.toString p}:${builtins.toString p}") ports)
        } --user 1000:1000 --userns keep-id:uid=1000,gid=1000\
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
        --user 1000:1000 --userns keep-id:uid=1000,gid=1000\
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
    ++ (checkDir "ml" mkDevContainerCommands)
    ++ (checkDir "cv" (mkDevPortsContainerCommands [ 1111 ]));
}
