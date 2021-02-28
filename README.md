# nix-config-darwin

This is my configuraton of nix package manager in MacOS. First I installed
[homebrew](https://brew.sh/) because `nix` is more than just a package manager!
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
So it can wrap other package managers like `brew` and make them more useful.
Then I installed `nix` itself like this

```
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
```

As you can find in [Nix manual](https://nixos.org/manual/nix/stable/#sect-macos-installation).
In the end, I installed [home-manager](https://github.com/nix-community/home-manager).

You can repeate it as the selling point of `nix` is being repeatable. You just need to create `.local/config.nix` file with your user name and home directory.
```
{}:
let
  userName = "your user name";
  homeDirectory = "/Users/${userName}";
in {
  userName = userName;
  homeDirectory = homeDirectory;
}
```
Then run `home-manager switch` and done! All my packages/apps are in your machine with the same configuration.
