{ stdenv, pkgs, ... }: homeDirectory:
# with import <nixpkgs> {};

let
  appsList = [
    "firefox"
    "chromium"
    "clipy"
    "keepassx"
    "openvpn-connect"
    "gimp"
    "skype"
  ];
  apps = builtins.concatStringsSep " " appsList;
  myScript = pkgs.writeShellScriptBin "brew-installer-script" ''
    export PATH=/bin:/usr/bin:/usr/local/bin
    export HOME=${homeDirectory}
    mkdir $out

    cd $HOME
    brew install ${apps}  || true
  '';
in
stdenv.mkDerivation rec {
  name = "brew-installer-derivation";

  builder = "${pkgs.bash}/bin/bash";
  args = [ "${myScript}/bin/brew-installer-script" ];
  buildInputs = [];
  system = builtins.currentSystem;
}

