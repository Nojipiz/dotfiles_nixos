let 
  wallpapers = [
    ../../../../media/wallpaper/initiald.jpg
    ../../../../media/base_wallpaper.png
  ];
in {
  imports = [
    ../../../../common/home

    ./sway
    ./waybar
  ];

  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "24.11";
  };

  home.file = { 
    "Images/wallpaper/base_wallpaper.png" = {
      source = builtins.head wallpapers;
    };
  };
}
