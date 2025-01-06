{ nix-darwin, home-manager, ... }:

nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [ 
    ../../arch/darwin
    ../../common/modules/development
    ../../common/modules/development/jvm
    ../../common/modules/development/js
    ../../common/modules/virtualization
    ../../common/modules/shell

    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.nojipiz = ../../arch/darwin/home/default.nix;
    }
  ];
}
