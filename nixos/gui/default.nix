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
    anydesk
    slack

    unstable.postman
    unstable.android-studio 
  ];
}
