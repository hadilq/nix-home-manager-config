{ pkgs ? import <nixpkgs> { } }:
let
  userHome = "${builtins.toString ./.user-home}";
  jupyter = pkgs.python3.withPackages (ps: with ps; [
    ipykernel
    jupyterlab
    matplotlib
    numpy
    sympy
  ]);
in
(pkgs.buildFHSUserEnv {
  name = "jupyter-shell";
  targetPkgs = pkgs: (with pkgs; [
    jupyter
  ]);
  runScript = "bash";
  profile = ''
    export HOME=${userHome}
  '';
}).env
