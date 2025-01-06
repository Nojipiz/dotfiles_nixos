{
  description = "Nojipiz's systems configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin 
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # Minecraft
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, nixpkgs-unstable, ... }:
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
      NixosWayland = import ./host/blue-bird/nixos-wayland.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
      NixosX11 = import ./host/blue-bird/nixos-x11.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
      WSL = import ./host/wolf-sea-lion/default.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
    };

    darwinConfigurations = {
      Davids-MacBook-Pro = ./host/black-apple/default.nix {
        inherit nix-darwin home-manager;
      };
    };
  };
}

