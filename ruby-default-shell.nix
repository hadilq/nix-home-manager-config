let pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  name = "env";
  buildInputs = with pkgs; [
    ruby.devEnv
    git
    libpcap
    libxml2
    libxslt
    pkg-config
    bundix
    gnumake
  ];
}

