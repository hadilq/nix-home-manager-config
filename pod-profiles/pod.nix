# A fork of https://github.com/NixOS/nix/blob/eeecbb9c364a29bbbde26aa41cc74204546950c0/docker.nix
{ system ? "x86_64-linux"
, pkgs
, home-manager-source
, name
, nixosConfiguration
, homeManagerConfiguration
, nixpkgsChannelName ? "nixpkgs"
, nixpkgsChannelURL
, homeChannelName ? "home-manager"
, homeChannelURL
, lib ? pkgs.lib
, tag ? "latest"
, bundleNixpkgs ? true
, username ? "dev"
, userHome ? "/home/dev"
, mountingDir ? "${userHome}/src"
, userConfig ? {
    uid = 1000;
    shell = "${pkgs.zsh}/bin/zsh";
    home = userHome;
    gid = 1000;
    groups = [ username ];
    description = "A normal user";
  }
, groupConfig ? {
    gid = 1000;
  }
, maxLayers ? 100
, nixos ? (import  "${pkgs.path}/nixos" {
    configuration = { config, pkgs, modulesPath, ... }: {
      imports = [
        "${toString modulesPath}/virtualisation/docker-image.nix"
        (import nixosConfiguration)
        (import "${home-manager-source}/nixos")
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = { config, pkgs, lib, ... } :{
          imports = [
            (import homeManagerConfiguration)
          ];

          programs.home-manager.enable = true;
          home.username = username;
          home.homeDirectory = userHome;

          home.stateVersion = "23.11";
        };
      };

      boot.isContainer = true;
      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      services.journald.console = "/dev/console";

      environment.noXlibs = lib.mkForce false;
      services.xserver = {
        enable = true;
        layout = "us";
        displayManager.lightdm.enable = false;
        displayManager.startx.enable = false;
      };

      users = {
        mutableUsers = true;
        users = {
          ${username} = {
            isNormalUser = true;
            home = userHome;
            description = "Development";
            extraGroups = [ ];
	          shell = pkgs.bashInteractive;
          };
        };
      };

      time.timeZone = "Canada/Eastern";
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "JetBrainsMono Nerd Font";
        keyMap = "us";
      };

      environment.systemPackages = with pkgs; [
        nix
        bashInteractive
        coreutils-full
        gnutar
        gnugrep
        gzip
        which
        curl
        less
        man
        cacert
        vim
      ];

      fonts.fonts = with pkgs; [
        nerdfonts
      ];

      system.stateVersion = "23.11";
    };
    inherit system;
  })
, flake-registry ? (pkgs.formats.json { }).generate "flake-registry.json" {
    version = 2;
    flakes = pkgs.lib.mapAttrsToList (n: v: { inherit (v) from to exact; }) ({
      nixos = {
        from = { type = "indirect"; id = "nixos"; };
        to = pkgs.path;
        exact = true;
      };
      nixpkgs = {
        from = { type = "indirect"; id = "nixpkgs"; };
        to = pkgs.path;
        exact = true;
      };
    });
  }
}:
let
  defaultPkgs = with pkgs; [
    nixos.config.system.path
  ];

  users = {

    root = {
      uid = 0;
      shell = "${pkgs.zsh}/bin/zsh";
      home = "/root";
      gid = 0;
      groups = [ "root" ];
      description = "System administrator";
    };

    ${username} = userConfig;

    nobody = {
      uid = 65534;
      shell = "${pkgs.shadow}/bin/nologin";
      home = "/var/empty";
      gid = 65534;
      groups = [ "nobody" ];
      description = "Unprivileged account (don't use!)";
    };

  } // lib.listToAttrs (
    map
      (
        n: {
          name = "nixbld${toString n}";
          value = {
            uid = 30000 + n;
            gid = 30000;
            groups = [ "nixbld" ];
            description = "Nix build user ${toString n}";
          };
        }
      )
      (lib.lists.range 1 32)
  );

  groups = {
    root.gid = 0;
    ${username} = groupConfig;
    nixbld.gid = 30000;
    nobody.gid = 65534;
  };

  userToPasswd = (
    k:
    { uid
    , gid ? 65534
    , home ? "/var/empty"
    , description ? ""
    , shell ? "/bin/false"
    , groups ? [ ]
    }: "${k}:x:${toString uid}:${toString gid}:${description}:${home}:${shell}"
  );
  passwdContents = (
    lib.concatStringsSep "\n"
      (lib.attrValues (lib.mapAttrs userToPasswd users))
  );

  userToShadow = k: { ... }: "${k}:!:1::::::";
  shadowContents = (
    lib.concatStringsSep "\n"
      (lib.attrValues (lib.mapAttrs userToShadow users))
  );

  # Map groups to members
  # {
  #   group = [ "user1" "user2" ];
  # }
  groupMemberMap = (
    let
      # Create a flat list of user/group mappings
      mappings = (
        builtins.foldl'
          (
            acc: user:
              let
                groups = users.${user}.groups or [ ];
              in
              acc ++ map
                (group: {
                  inherit user group;
                })
                groups
          )
          [ ]
          (lib.attrNames users)
      );
    in
    (
      builtins.foldl'
        (
          acc: v: acc // {
            ${v.group} = acc.${v.group} or [ ] ++ [ v.user ];
          }
        )
        { }
        mappings)
  );

  groupToGroup = k: { gid }:
    let
      members = groupMemberMap.${k} or [ ];
    in
    "${k}:x:${toString gid}:${lib.concatStringsSep "," members}";
  groupContents = (
    lib.concatStringsSep "\n"
      (lib.attrValues (lib.mapAttrs groupToGroup groups))
  );

  defaultNixConf = {
    sandbox = "false";
    build-users-group = "nixbld";
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixConfContents = (lib.concatStringsSep "\n" (lib.mapAttrsFlatten (n: v:
    let
      vStr = if builtins.isList v then lib.concatStringsSep " " v else v;
    in
      "${n} = ${vStr}") defaultNixConf)) + "\n";

  endpointScript = ''
    #!${pkgs.bashInteractive}/bin/bash

    /bin/nix-daemon &> /dev/null &

    # exec runuser -u ${username} "$@"
    /nix/var/nix/profiles/default/bin/tail -f /dev/null
  '';

  shells = lib.concatStringsSep "\n"  [
    "${pkgs.bashInteractive}/bin/bash"
    "${pkgs.zsh}/bin/zsh"
  ];

  userGroupIds = "${toString users.${username}.uid}:${toString groups.${username}.gid}";
  
  baseSystem =
    let
      nixpkgs = pkgs.path;
      channel = pkgs.runCommand "channel-nixos" { inherit bundleNixpkgs; } ''
        mkdir $out
        if [ "$bundleNixpkgs" ]; then
          ln -s ${nixpkgs} $out/nixpkgs
          echo "[]" > $out/manifest.nix
        fi
      '';
      nix-channels = pkgs.runCommand "nix-channels" {} ''
        mkdir $out
        cat > $out/.nix-channels <<EOF
        ${nixpkgsChannelURL} ${nixpkgsChannelName}
        ${homeChannelURL} ${homeChannelName}
        EOF
      '';
      rootEnv = pkgs.buildPackages.buildEnv {
        name = "root-profile-env";
        paths = defaultPkgs;
      };
      manifest = pkgs.buildPackages.runCommand "manifest.nix" { } ''
        cat > $out <<EOF
        [
        ${lib.concatStringsSep "\n" (builtins.map (drv: let
          outputs = drv.outputsToInstall or [ "out" ];
        in ''
          {
            ${lib.concatStringsSep "\n" (builtins.map (output: ''
              ${output} = { outPath = "${lib.getOutput output drv}"; };
            '') outputs)}
            outputs = [ ${lib.concatStringsSep " " (builtins.map (x: "\"${x}\"") outputs)} ];
            name = "${drv.name}";
            outPath = "${drv}";
            system = "${drv.system}";
            type = "derivation";
            meta = { };
          }
        '') defaultPkgs)}
        ]
        EOF
      '';
      profile = pkgs.buildPackages.runCommand "user-environment" { } ''
        mkdir $out
        cp -a ${rootEnv}/* $out/
        ln -s ${manifest} $out/manifest.nix
      '';
      flake-registry-path = if (flake-registry == null) then
        null
      else if (builtins.readFileType (toString flake-registry)) == "directory" then
        "${flake-registry}/flake-registry.json"
      else
        flake-registry;
    in
    pkgs.runCommand "base-system"
      {
        inherit passwdContents groupContents shadowContents nixConfContents endpointScript shells;
        passAsFile = [
          "passwdContents"
          "groupContents"
          "shadowContents"
          "nixConfContents"
          "endpointScript"
          "shells"
        ];
        allowSubstitutes = false;
        preferLocalBuild = true;
      } (''
      env
      set -x
      mkdir -p $out/etc

      cat $passwdContentsPath > $out/etc/passwd
      echo "" >> $out/etc/passwd

      cat $groupContentsPath > $out/etc/group
      echo "" >> $out/etc/group

      cat $shellsPath > $out/etc/shells
      echo "" >> $out/etc/shells

      cat $shadowContentsPath > $out/etc/shadow
      echo "" >> $out/etc/shadow

      cat $endpointScriptPath > $out/etc/endpoint.sh
      ln -s /nix/var/nix/profiles $out/etc/profiles

      mkdir -p $out/usr
      ln -s /nix/var/nix/profiles/share $out/usr/

      mkdir -p $out/nix/var/nix/gcroots

      mkdir $out/tmp

      mkdir -p $out/var/tmp

      mkdir -p $out/etc/nix
      cat $nixConfContentsPath > $out/etc/nix/nix.conf

      mkdir -p $out/root
      mkdir -p $out/nix/var/nix/profiles/per-user/root

      ln -s ${profile} $out/nix/var/nix/profiles/default-1-link
      ln -s $out/nix/var/nix/profiles/default-1-link $out/nix/var/nix/profiles/default
      ln -s /nix/var/nix/profiles/default $out/root/.nix-profile

      ln -s ${channel} $out/nix/var/nix/profiles/per-user/root/channels-1-link
      ln -s $out/nix/var/nix/profiles/per-user/root/channels-1-link $out/nix/var/nix/profiles/per-user/root/channels

      mkdir -p $out/root/.nix-defexpr
      ln -s $out/nix/var/nix/profiles/per-user/root/channels $out/root/.nix-defexpr/channels
      ln -s ${nix-channels}/.nix-channels $out/root/.nix-channels

      mkdir -p $out${userHome}
      mkdir -p $out${userHome}/.nix-defexpr
      ln -s $out/nix/var/nix/profiles/per-user/root/channels $out${userHome}/.nix-defexpr/channels
      ln -s ${nix-channels}/.nix-channels $out${userHome}/.nix-channels

      mkdir -p $out/bin $out/usr/bin
      ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
      ln -s ${pkgs.bashInteractive}/bin/bash $out/bin/bash

      # The ${username}-tmp will be renamed to ${username} in fakeRootCommands script.
      mkdir -p $out/nix/var/nix/profiles/per-user/${username}-tmp
      HOME_ACTIVATION=${nixos.config.home-manager.users.${username}.home.activationPackage}
      find ''${HOME_ACTIVATION}/home-path/\
        -maxdepth 1 -type d | while read dir; do
        ln -s $dir $out/nix/var/nix/profiles/per-user/${username}-tmp/$(basename $dir)
      done
      find ''${HOME_ACTIVATION}/home-path/\
        -maxdepth 1 -type l | while read slink; do
        ln -s $slink $out/nix/var/nix/profiles/per-user/${username}-tmp/$(basename $slink)
      done

    '' + (lib.optionalString (flake-registry-path != null) ''
      nixCacheDir="${userHome}/.cache/nix"
      mkdir -p $out$nixCacheDir
      globalisNormalUserFlakeRegistryPath="$nixCacheDir/flake-registry.json"
      ln -s ${flake-registry-path} $out$globalFlakeRegistryPath
      mkdir -p $out/nix/var/nix/gcroots/auto
      rootName=$(${pkgs.nix}/bin/nix --extra-experimental-features nix-command hash file --type sha1 --base32 <(echo -n $globalFlakeRegistryPath))
      ln -s $globalFlakeRegistryPath $out/nix/var/nix/gcroots/auto/$rootName
    ''));

in
pkgs.dockerTools.buildLayeredImageWithNixDb {

  inherit name tag maxLayers;

  contents = [ baseSystem ];

  extraCommands = ''
    rm -rf nix-support
    ln -s /nix/var/nix/profiles nix/var/nix/gcroots/profiles
  '';

  fakeRootCommands = ''
    chmod 1777 tmp
    chmod 1777 var/tmp
    
    export USER=${username}
    export HOME=${userHome}

    ${nixos.config.system.build.etcActivationCommands}

    # FIXME(hacky!) It's a symblink, so let's give home-manager a chance to make it properly.
    mv /nix/var/nix/profiles/per-user/{${username},root}
    mv /nix/var/nix/profiles/per-user/{${username}-tmp,${username}}

    HOME_ACTIVATION=${nixos.config.home-manager.users.${username}.home.activationPackage}
    mkdir -p /build
    $HOME_ACTIVATION/activate

    # FIXME(hacky!) It's pointing to the per-user/root directory, so this fix it.
    rm ${userHome}/.nix-profile
    ln -s /nix/var/nix/profiles/per-user/${username} ${userHome}/.nix-profile

    chown ${ userGroupIds} /nix/var/nix/profiles/per-user/${username}
    chown -R ${ userGroupIds} /nix/var/nix/profiles/per-user/${username}
    chown ${ userGroupIds} ${userHome}
    find ${userHome} -type d | while read dir; do
      if [[ $dir != "${mountingDir}" ]] && [[ $dir != ${mountingDir}/* ]]; then
        chown ${ userGroupIds} $dir
      fi
    done
  '';

  enableFakechroot = true;

  created = "now";
  config = {
    Cmd = [ "/nix/var/nix/profiles/default/bin/bash" ];
    Entrypoint = [ "/nix/var/nix/profiles/default/bin/bash" "/etc/endpoint.sh" ];
    WorkingDir = userHome;
    User = userGroupIds;
    Home = userHome;
    Volumes = { };
    Env = [
      "USER=${username}"
      "PATH=${lib.concatStringsSep ":" [
        "${userHome}/.nix-profile/bin"
        "/nix/var/nix/profiles/default/bin"
        "/nix/var/nix/profiles/default/sbin"
      ]}"
      "MANPATH=${lib.concatStringsSep ":" [
        "${userHome}/.nix-profile/share/man"
        "/nix/var/nix/profiles/default/share/man"
      ]}"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "GIT_SSL_CAINFO=/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "NIX_PATH=/nix/var/nix/profiles/per-user/${username}/channels:${userHome}/.nix-defexpr/channels"
      "FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
      "FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts/"
      "TERM=xterm-256color"
    ];
  };

}

