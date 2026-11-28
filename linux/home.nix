{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  grok-bot,
  inputs,
  ...
}:
let
  zsh-nix = import ../pod-profiles/modules/zsh.nix { };
  neovim-nix = import ../pod-profiles/modules/neovim.nix { };
  cosmic-applets-nix = import ../modules/cosmic/applets.nix;
  wolfram-script-nix = pkgs.callPackage ../pod-profiles/modules/wolfram/wolfram-script.nix;
in
{
  imports = [
    ../modules/home.nix
    ./modules/autostart.nix
    ./modules/commands.nix
    ./modules/password-store.nix
    zsh-nix
    neovim-nix
    ../nixarchy/modules/hypr.nix
    ../nixarchy/modules/fonts.nix
    ../nixarchy/modules/idle-sleep.nix
    ../nixarchy/modules/apps.nix
    # cosmic-panel-config is depending on git+https! Waiting for the fix of https://github.com/pop-os/cosmic-panel/blob/1c9c4e2a2cf27efd0ca77b5ec21bc6f7fa92d9da/Cargo.lock#L4239
    #cosmic-applets-nix
    #wolfram-script-nix
  ];

  programs.nixarchy = {
    enable = true;
    # Leave ~/.config/nvim alone: no Omarchy LazyVim seed, no theme.lua link,
    # no neovimSpecs. programs.neovim is provided by neovim-nix.
    neovim = "off";
  };

  services.nixi.enable = false;

  # Client for the secret-broker daemon (services.secret-broker in the NixOS
  # config): `secret-broker unlock/lock/status`, `secret-run <profile> ...`.
  programs.secret-broker.enable = true;
  programs.secret-broker.gpgAgent.recommended = true;

  # Run AI agents in a bubblewrap sandbox (ai-run, from the secret-broker
  # flake): credential paths masked (browsers, gh, gnupg, keyrings, Proton
  # Pass, other agents' logins...), $HOME read-only except ~/dev,
  # ~/Documents, ~/.cache..., no session bus / gpg-agent / Hyprland IPC.
  # `wrap` replaces each package's binaries and .desktop entries with
  # ai-run wrappers, so Omarchy's agent launcher (SUPER+SHIFT+CTRL+A ->
  # omarchy-agent -> grok) and the app menu go through the sandbox.
  # `ai-run --list` shows the profiles; `ai-run` alone gives a sandboxed shell.
  programs.ai-run = {
    enable = true;
    wrap = [
      # Same derivation as in ../nixarchy/modules/apps.nix (same nixpkgs).
      (import pkgs.path {
        inherit (pkgs) system;
        config.allowUnfreePredicate = pkg: lib.getName pkg == "grok-build";
      }).grok-build
      # Grok Bot desktop app; its tool commands run in a nested sandbox
      # that also hides the app's own login (~/.config/Grok Bot, ~/.grokbot).
      {
        package = grok-bot.packages.${pkgs.system}.default;
        profile = "grok-bot";
      }
    ];
  };

  home.packages = with pkgs; [
    # Standalone home-manager can't see the NixOS nixarchy module, so nixarchy
    # adds the omarchy package's runtimeDeps (including plain pkgs.neovim) to
    # home.packages. That collides with programs.neovim's wrapper in buildEnv
    # (two different bin/nvim). Give our configured wrapper priority.
    (lib.hiPrio config.programs.neovim.finalPackage)
    aspell
    aspellDicts.en
    aspellDicts.ca
    thunderbird
    vlc
    audacity
    keepassxc
    libreoffice
    gimp
    bitwarden-cli
    imagemagick
    virt-manager
    rclone
    inkscape
    wl-clipboard
    pkgs-unstable.ladybird
    kdePackages.okular # remember https://askubuntu.com/questions/54794/cannot-view-pdf-files-with-fillable-fields-with-okular/298942#298942
    speedcrunch
    loupe
    socat
    age
    sops
    # Zen from nixarchy's zen-browser flake input (upstream's own flake,
    # bumped with `nix flake update nixarchy`); binary is `zen-beta`.
    inputs.nixarchy.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser
    git-lfs-transfer
    grok-bot.packages.${pkgs.system}.default
    proton-pass
  ];
}
