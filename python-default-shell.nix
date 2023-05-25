{ pkgs ? import <nixpkgs> { } }:
let
  userHome = "${builtins.toString ./.user-home}";
in
(pkgs.buildFHSUserEnv {
  name = "python-shell";
  targetPkgs = pkgs: (with pkgs; [
    python38Packages.pip
    python38Packages.wheel
    python38Packages.pyyaml
    python38Packages.jsonschema
    ncurses6
  ]);
  runScript = "bash";
  profile = ''
    export HOME=${userHome}
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    unset SOURCE_DATE_EPOCH
    export LD_LIBRARY_PATH=$(nix eval --raw nixpkgs.ncurses6)/lib:$LD_LIBRARY_PATH
  '';
}).env
