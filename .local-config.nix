{ }:
let
  userName = "hadi";
  # gitEmail = "your git email";
  # gitName = "your git name";
  # gitSigningKey = "your git signature key";
in {
  inherit userName;
  userName = userName;
  gitEmail = gitEmail;
  gitName = gitName;
  gitSigningKey = gitSigningKey;
  homeDirectory = "/home/${userName}"; # or "/Users/${userName}"
  system = "x86_64-linux"; # or aarch64-darwin
  local-projects = {
    ml-dir = "/home/hadi/...";
    crawler-dir = "/home/hadi/...";
  };
}
