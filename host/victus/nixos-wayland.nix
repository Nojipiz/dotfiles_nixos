{ nixpkgs, system, home-manager, overlay-unstable,  ... }:
let 
  extrasModule = { pkgs, ... }:{
    environment.systemPackages = [
      pkgs.home-manager
      pkgs.obs-studio
      pkgs.anydesk
      pkgs.slack
    ];
    environment.loginShellInit = ''
      if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
          sway --unsupported-gpu -V > .sway-log 2>&1
      fi
    '';
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
        users.nojipiz = ../../arch/nixos/home/desktop-sway/default.nix;
      };
    }
  ];
}
