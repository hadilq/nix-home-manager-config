# nix-home-manager-config

This is my configuraton of nix package manager in MacOS and NixOS.

## NixOS
Just install the [home-manager](https://github.com/nix-community/home-manager).

## MacOS
First I installed [homebrew](https://brew.sh/) because `nix` is more than just a package manager!

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

## Both NixOS and MacOS
After installing [home-manager](https://github.com/nix-community/home-manager),
clone this repository into `~/.config/nixpkgs`. Next step is creating `.local/config.nix`
file with your username and home directory with a content similar to the following one.

```
{}:
let
  userName = "your user name";
in {
  userName = userName;
  gitEmail = "your git email";
  gitName = "your git name";
  gitSigningKey = "your siging key for git";
  homeDirectory =  "/Users/${userName}";
}
```

Then run `home-manager switch` and done! All the packages/apps are in new machine with the same configuration.

