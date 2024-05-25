{
  config,
  pkgs,
  lib,
  ...
}: 
let
  jupyterlabVim = (with pkgs; with pkgs.python3.pkgs; buildPythonPackage rec {
    pname = "jupyterlab_vim";
    version = "4.1.0";
    format = "pyproject";

    disabled = pythonOlder "3.7";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-EdhQ7pGyhkp7Ypiq5GUhmoIvjMxuAfI/oD8e5hev4zA=";
    };

    nativeBuildInputs = [
      hatchling
      jupyterlab
      hatch-nodejs-version
      hatch-jupyter-builder
    ];

    nativeCheckInputs = [
      pytest-jupyter
    ];

    prePatch = ''
      export HOME=$(mktemp -d)
    '';

    meta = with lib; {
      description = "Vim notebook cell bindings for JupyterLab";
      homepage = "https://github.com/jwkvam/jupyterlab-vim";
      license = licenses.mit;
      maintainers = lib.teams.jupyter.members;
    };
  });

  jupyter = pkgs.python3.withPackages (ps: with ps; [
    jupyter
    ipython
    ipykernel
    jupyterlab
    jupyterlabVim
    matplotlib
    numpy
    sympy
    pathos
    tensorflow
    keras
    sklearn-deap
    sentencepiece
    datasets
    transformers
    ipywidgets
    jupyterlab-widgets
    widgetsnbextension
    pip
  ]);

  zsh-nix = import ./../common/zsh.nix { };
in
{

  imports = [
    zsh-nix
  ];

  home.packages = with pkgs; [
    jupyter
    sageWithDoc
    nerdfonts
    git-lfs
  ];

  programs.firefox = {
    enable = true;
  };

  programs.zsh = {
    initExtra = ''
      export JUPYTERLAB=$HOME/jupyterlab
      export SAGEMATH=${pkgs.sageWithDoc}
    '';
  };
}

