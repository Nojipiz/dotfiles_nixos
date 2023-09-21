{ config, pkgs, ... }:

{
  imports = [
    ./i3.nix
    ./alacritty.nix
    ./zellij/zellij.nix
    ./android/android.nix
    ./lunarvim/lunarvim.nix
    ./polybar/polybar.nix
  ];
  home = {
    username = "nojipiz";
    homeDirectory = "/home/nojipiz";
    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;

  home.file = { 
    "Images/wallpaper/base_wallpaper.png" = {
      source = media/base_wallpaper.png;
    };
  };
}
