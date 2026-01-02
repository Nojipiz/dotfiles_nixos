{
  description = "Nojipiz's systems configuration";

  nixConfig = {
    # Configuration for Cachix to avoid redundand rebuilds
    # https://app.cachix.org/
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia Flake: https://docs.noctalia.dev/getting-started/nixos/
    noctalia-flake = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      nixpkgs-unstable,
      ...
    }:

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
        NixosWaylandNiri = import ./host/victus/nixos-niri.nix {
          inherit
            inputs
            nixpkgs
            system
            home-manager
            overlay-unstable
            ;
        };
        WSL = import ./host/any-windows/default.nix {
          inherit
            nixpkgs
            system
            home-manager
            overlay-unstable
            ;
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
        desktopNiri = home-manager.lib.homeManagerConfiguration {
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
          modules = [ (import ./arch/nixos/home/desktop-niri/default.nix) ];
        };
      };
    };
}
