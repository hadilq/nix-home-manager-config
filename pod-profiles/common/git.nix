{ pkgs, lib, localConfig, ... }:
let
  inherit (pkgs) stdenv;
in {
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        editor = "vim";
        fileMode = false;
      };
      credential.helper = lib.optionals stdenv.isDarwin "osxkeychain";
    };

    includes = [{
      contents = {
        init.defaultBranch = "main";
        user = {
          email = localConfig.gitEmail;
          name = localConfig.gitName;
          signingKey = localConfig.gitSigningKey;
        };
        commit = {
          gpgSign = true;
        };
      };
    }];
  };

}
