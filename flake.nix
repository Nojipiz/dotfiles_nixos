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
      NixosWayland = import ./host/victus/nixos-wayland.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
      NixosX11 = import ./host/vivobook/nixos-x11.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
      WSL = import ./host/any-windows/default.nix {
        inherit nixpkgs system home-manager overlay-unstable;
      };
    };

    darwinConfigurations = {
      Davids-MacBook-Pro = import ./host/any-silicon/default.nix {
        inherit nix-darwin home-manager;
      };
    };

    # Standalone home-manager configuration entry point.
    # (To rebuild home-manager only)
    homeConfigurations = {
      desktopSway =
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
          modules = [ (import ./arch/nixos/home/desktop-sway/default.nix) ];
        };
    };
  };
}
