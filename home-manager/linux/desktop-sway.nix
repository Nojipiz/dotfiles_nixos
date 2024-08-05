{
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
      source = ../../media/base_wallpaper.png;
    };
  };

  programs.home-manager.enable = true;

}
