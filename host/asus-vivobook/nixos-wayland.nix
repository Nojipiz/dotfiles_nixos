{ nixpkgs, system, home-manager, overlay-unstable,  ... }:
let 
  customModule = { pkgs, ... }:{
    environment.systemPackages = with pkgs; [
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
        users.nojipiz = ../../arch/nixos/home/desktop-sway/default.nix;
      };
    }
  ];
}
