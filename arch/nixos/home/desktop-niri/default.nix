{ noctalia-flake }:
let
  wallpapers = [
    ../../../../media/wallpaper/initiald.jpg
    ../../../../media/base_wallpaper.png
  ];
in
{
  imports = [
    noctalia-flake.homeModules.default
    ../../../../common/home
    ./niri
    ./fuzzel
    ./noctalia
  ];

  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "25.05";
  };

  home.file = {
    "Images/wallpaper/base_wallpaper.png" = {
      source = builtins.head wallpapers;
    };
  };
}
