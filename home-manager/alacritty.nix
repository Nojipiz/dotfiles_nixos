{ lib, pkgs, ... }:

{
  programs.alacritty.settings = {
    colors.normal.black = "#000000";
    colors.normal.red = "#CD0000";
    colors.normal.green = "#00CD00";
    colors.normal.yellow = "#CDCD00";
    colors.normal.blue = "#0000EE";
    colors.normal.magenta = "#CD00CD";
    colors.normal.cyan = "#00CDCD";
    colors.normal.white = "#E5E5E5";
    colors.bright.black = "#7F7F7F";
    colors.bright.red = "#FF0000";
    colors.bright.green = "#00FF00";
    colors.bright.yellow = "#FFFF00";
    colors.bright.blue = "#5C5CFF";
    colors.bright.magenta = "#FF00FF";
    colors.bright.cyan = "#00FFFF";
    colors.bright.white = "#FFFFFF";
    colors.primary.background = "#000000";
    colors.primary.foreground = "#FFFFFF";
    font.normal.family = "Firacode";
    font.size = 9;
    live_config_reload = true;
    scrolling.history = 100000;
    working_directory = "/data";
  };
}
