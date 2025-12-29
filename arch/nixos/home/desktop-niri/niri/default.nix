{
  pkgs,
  ...
}:
{
  # Configuration for portals.
  # Implementations should be consistent with other xdg.portal references.
  xdg.portal.config.niri = {
    default = [ "wlr" ];
    "org.freedesktop.impl.portal.Access" = "wlr";
    "org.freedesktop.impl.portal.Notification" = "wlr";
    "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    "org.freedesktop.impl.portal.FileChooser" = "wlr";
    "org.freedesktop.impl.portal.ScreenCast" = "wlr";
    "org.freedesktop.portal.ScreenCast" = "wlr";
  };

  # Copies the niri config directory as read-only.
  home.file.".config/niri" = {
    source = config/niri;
  };
}
