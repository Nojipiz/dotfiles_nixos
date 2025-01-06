{
  description = "Nojipiz's systems configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
  };

  outputs = { nixpkgs, home-manager, nixpkgs-unstable, ... }:
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

      Darwin = nixpkgs.lib.nixosSystem {
        # TODO: Implement this
      };
    };
  };
}

