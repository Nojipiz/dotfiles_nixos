# Nojipiz NixOS Configuration

![Desktop Preview](https://github.com/nojipiz/dotfiles_nixos/blob/main/media/screenshot/desktop.png?raw=true)

To run the config, download and install Nix and then run for your system:

## NixOs
To install NixOs should be done using the official installer: https://nixos.org/download/

- X11 + i3wm
```bash
sudo nixos-rebuild switch --flake "./nix-config#NixosX11"
```

- Wayland + Sway
```bash
sudo nixos-rebuild switch --flake "./nix-config#NixosWayland"
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

Then, there is configuration required for my keyboard (Lily58) to work, just change 'Modifier Keys' and set: 

- Command to Option
- Option to Command

The mouse is inverted, it's necessary to change 'Natural scrolling' to false. (and probably to increase the tracking speed).
