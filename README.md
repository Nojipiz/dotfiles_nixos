# Nojipiz NixOS Configuration

![Desktop Preview](https://github.com/nojipiz/dotfiles_nixos/blob/main/media/screenshot/desktop.png?raw=true)

To run the config, download and install Nix and then run for your system:

## NixOs
To install NixOs should be done using the official installer: https://nixos.org/download/

- Niri on Wayland 
```bash
sudo nixos-rebuild switch --flake "./nix-config#NixosNiri"
```

## WSL
WSL should be installed, and NixOs should be installed from here: https://github.com/nix-community/NixOS-WSL

- Running the flake
```bash
sudo nixos-rebuild switch --flake "./nix-config#WSL" --impure
```

## MacOs
Here is recommended to use the installer from DeterminateSystems, can be found here: https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer

This is a especial case, the nix flake isn't able to install `homebrew` so it's necesary to run two commands.
- Installing Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- Running the flake
```bash
 nix run nix-darwin -- switch --flake ~/Documents/dotfiles_nixos
```

The mouse is inverted, it's necessary to change 'Natural scrolling' to false. (and probably to increase the tracking speed).

There is more config, like Chrome windows that require modified shortcuts (still don't know if those are available here).

## home-manager standalone module.
To build **just** your home-manager config, you can use this module.
TODO: Add home-manager as standalone too to all configs.
```bash
home-manager switch --flake "./nix-config#desktopNiri"
```

## Lily58 keyboard.
My configuration for the keyboard is stored at  `lily58_layout.json`, can be applied using [VIA](https://www.usevia.app/)
