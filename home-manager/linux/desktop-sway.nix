let 
  wallpapers = [
    ../../media/wallpaper/initiald.jpg
    ../../media/base_wallpaper.png
  ];
in {
  imports = [
    ../base/desktop

    ./desktop/sway
    ./desktop/waybar
  ];

  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "24.05";
  };

  home.file = { 
    "Images/wallpaper/base_wallpaper.png" = {
      source = builtins.head wallpapers;
    };
  };

  programs.home-manager.enable = true;
}
