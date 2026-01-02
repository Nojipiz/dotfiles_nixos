let
  wallpapers = [
    ../../../../../media/wallpaper/initiald.jpg
    ../../../../../media/base_wallpaper.png
  ];
in
{
  # Noctalia config.
  home.file.".config/noctalia" = {
    source = config/noctalia;
  };

  # Wallpaper config
  # see https://docs.noctalia.dev/getting-started/nixos/#wallpapers
  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = builtins.head wallpapers;
    };
  };
}
