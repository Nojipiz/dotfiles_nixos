{ nix-darwin, home-manager, ... }:

nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [ 
    ../../arch/darwin/default.nix

    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.nojipiz = ../../arch/wsl/home/default.nix;
    }
  ];
}
