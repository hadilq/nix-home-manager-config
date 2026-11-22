let
  userName = "hadi";
  gitEmail = "hadilq.dev@gmail.com";
  gitName = "Hadi";
  gitSigningKey = "EA378A19A23CF576";
in {
  inherit userName gitEmail gitName gitSigningKey;
  homeDirectory = "/home/${userName}"; # or "/Users/${userName}"
  system = "x86_64-linux"; # or aarch64-darwin
  local-projects = {
  };
}
