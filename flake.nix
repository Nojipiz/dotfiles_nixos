{
  description = "Nojipiz's systems configuration";

  nixConfig = {
    # Configuration for Cachix to avoid redundand rebuilds
    # https://app.cachix.org/
    extra-substituters = [
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
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

    # Niri WM Flake
    # I depend on this until screensharing is possible without xwayland-satellite.
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      nixpkgs-unstable,
      niri-flake,
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
            niri-flake
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
