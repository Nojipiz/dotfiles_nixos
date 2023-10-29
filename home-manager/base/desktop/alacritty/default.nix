{ lib, pkgs, ... }:

{
  programs.alacritty.enable = true;
  programs.alacritty.package = pkgs.alacritty;
  programs.alacritty.settings = {
    shell.program = "${pkgs.fish}/bin/fish";
    colors.normal.black = "#15161E";
    colors.normal.red = "#f7768e";
    colors.normal.green = "#9ece6a";
    colors.normal.yellow = "#e0af68";
    colors.normal.blue = "#7aa2f7";
    colors.normal.magenta = "#bb9af7";
    colors.normal.cyan = "#7dcfff";
    colors.normal.white = "#a9b1d6";
    colors.bright.black = "#414868";
    colors.bright.red = "#f7768e";
    colors.bright.green = "#9ece6a";
    colors.bright.yellow = "#e0af68";
    colors.bright.blue = "#7aa2f7";
    colors.bright.magenta = "#bb9af7";
    colors.bright.cyan = "#7dcfff";
    colors.bright.white = "#c0caf5";
    colors.primary.background = "#1a1b26";
    colors.primary.foreground = "#c0caf5";
    font.normal.family = "Firacode";
    font.size = 8;
    live_config_reload = true;
  };
}
