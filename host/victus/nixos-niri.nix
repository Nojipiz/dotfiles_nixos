{
  inputs,
  nixpkgs,
  system,
  home-manager,
  overlay-unstable,
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    { nixpkgs.overlays = [ overlay-unstable ]; }
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
    ../../arch/nixos/modules/wayland_niri

    home-manager.nixosModules.home-manager
    {
      environment.systemPackages = [ home-manager ];
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        users.nojipiz = import ../../arch/nixos/home/desktop-niri/default.nix {
          noctalia-flake = inputs.noctalia-flake;
        };
      };
    }
  ];
}
