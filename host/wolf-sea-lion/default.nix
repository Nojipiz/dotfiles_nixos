{ nixpkgs, system, home-manager, overlay-unstable,  ... }:
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ( 
     { config, pkgs, ... }: {
     nixpkgs.overlays = [ overlay-unstable ];
     }
    )
    ./networking
    ../../common/modules/browser
    ../../common/modules/development
    ../../arch/wsl

    home-manager.nixosModules.home-manager {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        users.nojipiz = ../../arch/wsl/home/default.nix;
      };
    }
  ];
}
