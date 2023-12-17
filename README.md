# Nojipiz NixOS Configuration

To run the config, download and install Nix and then run for your system:

- NixOs
```bash
sudo nixos-rebuild switch --flake "./nix-config#OLap"
```

- Windows Subsystem for Linux (aka WSL)
```bash
sudo nixos-rebuild switch --flake "./nix-config#WSL" --impure
```
