{
  description = "Nojipiz's system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
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

      OLap = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })

          ./nixos/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.nojipiz = ./home-manager/home.nix;
            };
          }
        ];
      };

    };
  };
}

