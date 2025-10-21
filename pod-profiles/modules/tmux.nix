{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
in
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    extraConfig = ''
      set-window-option -g mode-keys vi
      set-option -g history-limit 20000

      bind-key -n C-H swap-window -t -1\; select-window -t -1
      bind-key -n C-L swap-window -t +1\; select-window -t +1

      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${if stdenv.isDarwin then "pbcopy" else  "wl-clip -in -selection clipboard"}"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${if stdenv.isDarwin then "pbcopy" else  "wl-clip -in -selection clipboard"}"
    '';
  };
}
