{ pkgs, ... }:

{
  imports = [
    ./base/default.nix
    ./extra/default.nix
  ];

  # GUI packages
  environment.systemPackages = with pkgs; [
    alacritty
    pcmanfm
    chromium
    vlc
    anydesk
    unstable.postman
    xdg-utils
    redshift

    # More related to screen?
    feh 
    rofi
    polybarFull
  ];
}
