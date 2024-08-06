# Nojipiz NixOS Configuration

![Desktop Preview](https://github.com/nojipiz/dotfiles_nixos/blob/main/media/screenshot/desktop.png?raw=true)

To run the config, download and install Nix and then run for your system:

- NixOs
```bash
sudo nixos-rebuild switch --flake "./nix-config#Linux"
```

- Windows Subsystem for Linux (aka WSL)
```bash
sudo nixos-rebuild switch --flake "./nix-config#WSL" --impure
```
