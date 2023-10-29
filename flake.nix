{
  description = "Nojipiz's system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
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
          ( 
            { config, pkgs, ... }: { 
              nixpkgs.overlays = [ overlay-unstable ]; 
            }
          )
          ./nixos-modules/browser
          ./nixos-modules/controllers
          ./nixos-modules/dev
          ./nixos-modules/games
          ./nixos-modules/hardware
          ./nixos-modules/networking
          ./nixos-modules/nix
          ./nixos-modules/terminal
          ./nixos-modules/ui
          ./nixos-modules/user

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.nojipiz = ./home-manager/linux/desktop-i3.nix;
            };
          }
        ];
      };
    };
  };
}

