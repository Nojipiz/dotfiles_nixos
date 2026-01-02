{ noctalia-flake }:
{
  imports = [
    noctalia-flake.homeModules.default
    ../../../../common/home
    ./niri
    ./noctalia
  ];

  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "25.05";
  };
}
