# Nojipiz NixOS Configuration

![Desktop Preview](https://github.com/nojipiz/dotfiles_nixos/blob/main/media/screenshot/desktop.png?raw=true)

To run the config, download and install Nix and then run for your system:

- NixOs (X11 + i3wm)
```bash
sudo nixos-rebuild switch --flake "./nix-config#NixosX11"
```

- NixOs (Wayland + Sway)
```bash
sudo nixos-rebuild switch --flake "./nix-config#NixosWayland"
```

- Windows Subsystem for Linux (aka WSL)
```bash
sudo nixos-rebuild switch --flake "./nix-config#WSL" --impure
```

- MacOS
This is a especial case, the nix flake isn't able to install `homebrew` so it's necesary to run two commands.
```bash
sudo nixos-rebuild switch --flake "./nix-config#WSL" --impure
```
