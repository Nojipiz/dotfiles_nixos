{
  imports = [
    ../base/desktop

    ./desktop/i3
    ./desktop/polybar
  ];

  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "23.05";
  };

  home.file = { 
    "Images/wallpaper/base_wallpaper.png" = {
      source = ../../media/base_wallpaper.png;
    };
  };

  programs.home-manager.enable = true;
}
