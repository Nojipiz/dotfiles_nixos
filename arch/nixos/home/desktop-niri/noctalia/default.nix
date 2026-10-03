let
  wallpaperDir = "Pictures/Wallpapers";
in
{
  home.file.".config/noctalia" = {
    source = config/noctalia;
  };
  home.sessionVariables.TERMINAL = "alacritty";

  home.file."${wallpaperDir}/base_wallpaper.png" = {
    source = ../../../../../media/base_wallpaper.png;
  };
}
