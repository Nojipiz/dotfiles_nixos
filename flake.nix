{
  description = "Nojipiz's systems configuration";

  nixConfig = {
    # Configuration for Cachix to avoid redundand rebuilds
    # https://app.cachix.org/
    extra-substituters = [
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Minecraft
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";

    # Niri WM
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, nix-darwin, home-manager, nixpkgs-unstable, niri-flake, ... }:

  let
    system = "x86_64-linux";
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in
  {
    nixosConfigurations = {
      NixosWayland = import ./host/victus/nixos-wayland.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
      NixosWaylandNiri = import ./host/victus/nixos-niri.nix {
        inherit nixpkgs system home-manager overlay-unstable niri-flake;
      };
      WSL = import ./host/any-windows/default.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
    };

    # Configurations for darwin (MacOS) Nix package manager.
    darwinConfigurations = {
      Davids-MacBook-Pro = import ./host/any-silicon/default.nix {
        inherit nix-darwin home-manager;
      };
    };

    # Standalone home-manager configuration entry point.
    # (To rebuild home-manager only)
    homeConfigurations = {
      desktopHyprland =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = system;
            overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  system = system;
                  config.allowUnfree = true;
                };
              })
            ];
            config.allowUnfree = true;
          };
          modules = [ (import ./arch/nixos/home/desktop-hyprland/default.nix) ];
        };
    };
  };
}
