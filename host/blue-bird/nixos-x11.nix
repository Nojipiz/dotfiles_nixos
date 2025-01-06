{ nixpkgs, system, home-manager, overlay-unstable,  ... }:
let 
  customModule = {
    environment.systemPackages = with nixpkgs; [
      obs-studio
      anydesk
      slack
    ];
  };
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ( 
     { config, pkgs, ... }: {
     nixpkgs.overlays = [ overlay-unstable ];
     }
    )
    customModule
    ./hardware
    ./networking
    ./user
    ../../common/modules/browser
    ../../common/modules/development
    ../../common/modules/development/jvm
    ../../common/modules/development/js
    ../../common/modules/development/db
    ../../common/modules/development/cloud
    ../../common/modules/gaming
    ../../arch/nixos
    ../../arch/nixos/controllers
    ../../arch/nixos/x11

    home-manager.nixosModules.home-manager {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        users.nojipiz = ../../arch/nixos/desktop-i3/default.nix;
      };
    }
  ];
}
