{ nixpkgs, system, home-manager, overlay-unstable,  ... }:
let
  extrasModule = { pkgs, ... }:{
    # One - liner to add home-manager support, nothing else should be added here.
    environment.systemPackages = with pkgs; [ home-manager ];
  };
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    (
     { config, pkgs, ... }: {
       nixpkgs.overlays = [ overlay-unstable ];
     }
    )
    extrasModule
    ./hardware
    ./hardware/nvidia.nix
    ./networking
    ./user
    ../../common/modules/browser
    ../../common/modules/development
    ../../common/modules/development/jvm
    ../../common/modules/development/js
    ../../common/modules/development/db
    ../../common/modules/development/cloud
    ../../common/modules/development/haskell
    ../../common/modules/edition
    ../../common/modules/gaming
    ../../common/modules/misc
    ../../common/modules/shell
    ../../common/modules/virtualization

    ../../arch/nixos
    ../../arch/nixos/modules/controllers
    ../../arch/nixos/modules/wayland

    home-manager.nixosModules.home-manager {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        users.nojipiz = ../../arch/nixos/home/desktop-hyprland/default.nix;
      };
    }
  ];
}
