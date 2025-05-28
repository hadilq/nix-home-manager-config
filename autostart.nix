{ localConfig, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
  autostart-command = pkgs.writeShellScriptBin "autostart-command" ''
    count=1
    while ! ping -c 1 -W 1 172.217.165.14; do # google.com
      # notify-send --icon computer 'Waiting on network'
      sleep 3
      ((count++))
      if [ $count -eq 10 ]; then
          # notify-send --icon computer 'Unable to connect'
          break
      fi
    done

    # Browser
    tmux new-session -d -s firefox -n default
    tmux new-window -n hadi-pro -t firefox: 'firefox -P "hadi.pro" --no-remote'

    tmux new-session -d -s librewolf -n default
    tmux new-window -n proton -t librewolf: 'librewolf -P "proton" --no-remote'

    tmux new-session -d -s zen-browser -n default
    tmux new-window -n ml -t zen-browser: 'zen -P "ML" --no-remote'
    tmux new-window -n github -t zen-browser: 'zen -P "github" --no-remote'

    # Signal
    tmux new-session -d -s signal -n default
    tmux new-window -n run -t signal: 'signal-desktop'

    # home-manager
    tmux new-session -d -s home-manager -n default
    tmux new-window -n nvim -t home-manager: 'cd ~/.config/home-manager && nvim home.nix'
    tmux new-window -n nvim -t home-manager: 'cd ${localConfig.nixpkgs-dir} && nvim flake.nix'
    tmux new-window -n nvim -t home-manager: 'cd ${localConfig.nixos-config-dir} && nvim flake.nix'
  '';
in
{
  home.activation.autostart-command = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sfn  $VERBOSE_ARG \
      ${autostart-command}/bin/autostart-command \
      /home/${localConfig.userName}/.config/autostart/autostart-command
  '';
}
