{ config, pkgs, pkgs-unstable, ... }:
let
  cosmic-applets-nix = import ../modules/cosmic/applets.nix;
in
{
  imports = [
    ../modules/home.nix
    ./modules/autostart.nix
    ./modules/commands.nix
    # cosmic-panel-config is depending on git+https! Waiting for the fix of https://github.com/pop-os/cosmic-panel/blob/1c9c4e2a2cf27efd0ca77b5ec21bc6f7fa92d9da/Cargo.lock#L4239
    #cosmic-applets-nix
  ];

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.ca
    firefox
    thunderbird
    vlc
    audacity
    keepassxc
    libreoffice
    gimp
    gdrive
    bitwarden
    virt-manager
    kdePackages.krfb
    neovim-qt
    inkscape
    gsound
    libgda6
    wl-clipboard
    pkgs-unstable.signal-desktop
    libsForQt5.okular # remember https://askubuntu.com/questions/54794/cannot-view-pdf-files-with-fillable-fields-with-okular/298942#298942
    speedcrunch
    loupe
    socat
    age
    sops
    (callPackage ../pod-profiles/modules/zen.nix {})
  ];
}

