{
  localConfig,
  pkgs,
  lib,
  ...
}:
let
  inherit (localConfig) local-projects;
  signal = pkgs.writeTextFile {
    name = "signal-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Signal autostart
      Exec=signal-desktop
      Comment=Start Signal on desktop start
    '';
  };

  zen-ml = pkgs.writeTextFile {
    name = "zen-ml-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Zen ML autostart
      Exec=zen -P "ML" --no-remote
      Comment=Start Zen ML on desktop start
    '';
  };

  librewolf-proton = pkgs.writeTextFile {
    name = "librewolf-proton-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Librewold Proton autostart
      Exec=librewolf -P "proton" --no-remote
      Comment=Start Librewolf Proton on desktop start
    '';
  };

  librewolf-github= pkgs.writeTextFile {
    name = "librewolf-github-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Librewold Github autostart
      Exec=librewolf -P "github" --no-remote
      Comment=Start Librewolf Github on desktop start
    '';
  };

  firefox = pkgs.writeTextFile {
    name = "firefox-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Firefox autostart
      Exec=firefox -P "hadi.pro" --no-remote
      Comment=Start Firefox on desktop start
    '';
  };

  terminal = pkgs.writeTextFile {
    name = "terminal-desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Terminal autostart
      Exec=cosmic-term
      Comment=Start Terminal on desktop start
    '';
  };

  autostart-command = pkgs.writeShellScriptBin "autostart-command" ''
    # home-manager
    tmux new-session -d -s home-manager -n default
    ${lib.optionalString (builtins.hasAttr "home-manager-config-dir" local-projects) "tmux new-window -n nvim -t home-manager: 'cd ${local-projects.home-manager-config-dir} && nvim home.nix'"}
    ${lib.optionalString (builtins.hasAttr "nixpkgs-dir" local-projects) "tmux new-window -n nvim -t home-manager: 'cd ${local-projects.nixpkgs-dir} && nvim flake.nix'"}
    ${lib.optionalString (builtins.hasAttr "home-manager-dir" local-projects) "tmux new-window -n nvim -t home-manager: 'cd ${local-projects.home-manager-dir} && nvim flake.nix'"}
    ${lib.optionalString (builtins.hasAttr "nixos-config-dir" local-projects) "tmux new-window -n nvim -t home-manager: 'cd ${local-projects.nixos-config-dir} && nvim flake.nix'"}
  '';
in
{
  home.activation.autostart-command = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/${localConfig.userName}/.config/autostart
    rm -f /home/${localConfig.userName}/.config/autostart/*
    ln -sfn  $VERBOSE_ARG \
      ${autostart-command}/bin/autostart-command \
      /home/${localConfig.userName}/.config/autostart/autostart-command
    ln -sfn  $VERBOSE_ARG \
      ${zen-ml} \
      /home/${localConfig.userName}/.config/autostart/zen-ml.desktop
    ln -sfn  $VERBOSE_ARG \
      ${librewolf-proton} \
      /home/${localConfig.userName}/.config/autostart/librewolf-proton.desktop
    ln -sfn  $VERBOSE_ARG \
      ${librewolf-github} \
      /home/${localConfig.userName}/.config/autostart/librewolf-github.desktop
    ln -sfn  $VERBOSE_ARG \
      ${firefox} \
      /home/${localConfig.userName}/.config/autostart/firefox.desktop
    ln -sfn  $VERBOSE_ARG \
      ${signal} \
      /home/${localConfig.userName}/.config/autostart/signal.desktop
    ln -sfn  $VERBOSE_ARG \
      ${terminal} \
      /home/${localConfig.userName}/.config/autostart/terminal.desktop
  '';
}
