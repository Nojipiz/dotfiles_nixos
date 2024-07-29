{
  description = "Nojipiz's system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
      LinuxWayland = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ( 
            { config, pkgs, ... }: { 
              nixpkgs.overlays = [ overlay-unstable ]; 
            }
          )
          ./modules/nixos/browser
          ./modules/nixos/controllers
          ./modules/nixos/development
          ./modules/nixos/games
          ./modules/nixos/hardware
          ./modules/nixos/networking
          ./modules/nixos/ui/wayland
          ./modules/nixos/user

          # Architecture
          ./modules/nixos/nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.nojipiz = ./home-manager/linux/desktop-sway.nix;
            };
          }
        ];
      };
      LinuxX11 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ( 
            { config, pkgs, ... }: { 
              nixpkgs.overlays = [ overlay-unstable ]; 
            }
          )
          ./modules/nixos/browser
          ./modules/nixos/controllers
          ./modules/nixos/development
          ./modules/nixos/games
          ./modules/nixos/hardware
          ./modules/nixos/networking
          ./modules/nixos/ui/x11
          ./modules/nixos/user

          # Architecture
          ./modules/nixos/nix

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
      WSL = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ( 
            { config, pkgs, ... }: { 
              nixpkgs.overlays = [ overlay-unstable ]; 
            }
          )
          ./modules/nixos/browser
          ./modules/nixos/controllers
          ./modules/wsl/development
          ./modules/nixos/networking
          ./modules/nixos/user

          # Architecture
          ./modules/wsl

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

      Darwin = nixpkgs.lib.nixosSystem {
        # TODO: Implement this
      };
    };
  };
}

