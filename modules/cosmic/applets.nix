{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;

  clipboard-amanger-applet = pkgs.rustPlatform.buildRustPackage rec {
    pname = "cosmic-applet-clipboard-manager";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "cosmic-utils";
      repo = "clipboard-manager";
      rev = "30472d9333a88837f627d00ac0f2700c8234f52e";
      hash = "sha256-VSaoegakYI7BcqtgsCiYM47Qh20csEv/WWdNCdkZ3ys=";
    };

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "accesskit-0.16.0" = "sha256-yeBzocXxuvHmuPGMRebbsYSKSvN+8sUsmaSKlQDpW4w=";
        "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
        "clipboard_macos-0.1.0" = "sha256-tovB4fjPVVRY8LKn5albMzskFQ+1W5ul4jT5RXx9gKE=";
        "configurator_schema-0.1.0" = "sha256-tQmPTh0uhZhtHh/4PwJ5JvPMmhs2GiX2u/ijICWrReA=";
        "cosmic-client-toolkit-0.1.0" = "sha256-1XtyEvednEMN4MApxTQid4eed19dEN5ZBDt/XRjuda0=";
        "cosmic-config-0.1.0" = "sha256-VVxiIJanb9gs/7sYpXtsoDdsd+QDUg0QBpBpBWVTSqo=";
        "cosmic-panel-config-0.1.0" = "sha256-XbuTvUWS3Z3FMTSm1SYcGxxa5T6FGT2AQQ9uzXH+PlI=";
        "cosmic-text-0.12.1" = "sha256-nCw3RNIHINXH4+m9wKB+0CeoXSVKKxP+ylaZhfp8u+o=";
        "dpi-0.1.1" = "sha256-whi05/2vc3s5eAJTZ9TzVfGQ/EnfPr0S4PZZmbiYio0=";
        "iced_glyphon-0.6.0" = "sha256-u1vnsOjP8npQ57NNSikotuHxpi4Mp/rV9038vAgCsfQ=";
        "smithay-client-toolkit-0.19.2" = "sha256-DUn8MW+UN1nPIvX5+DWAwA37WUAdtdlOV4eJ0+5/CtM=";
        "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
        "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
        "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
        "wl-clipboard-rs-0.8.1" = "sha256-WnX6QKbb7j3RAdDnllNKeV5gbtkK3Crg5tnjwlIJ/eM=";
      };
    };

    nativeBuildInputs = with pkgs; [
      sqlite.dev sqlite just libxkbcommon
      just pkg-config util-linuxMinimal
    ];
    buildInputs = with pkgs; [ dbus glib libinput libxkbcommon wayland udev ];

    dontUseJustBuild = true;

    justFlags = [
      "--set" "prefix" (placeholder "out")
      "--set" "target" "${stdenv.hostPlatform.rust.cargoShortTarget}/release"
    ];

    # Force linking to libwayland-client, which is always dlopen()ed.
    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_RUSTFLAGS" =
      map (a: "-C link-arg=${a}") [
        "-Wl,--push-state,--no-as-needed"
        "-lwayland-client"
        "-Wl,--pop-state"
      ];
  };
in
{
  home.packages = lib.optionals stdenv.isLinux [
    clipboard-amanger-applet
  ];
}
