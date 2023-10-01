{ config, pkgs, ... }:

# let 
#   _pkgsOld = import (builtins.fetchTarball {
#       url = "https://github.com/NixOS/nixpkgs/archive/4426104c8c900fbe048c33a0e6f68a006235ac50.tar.gz";
#       sha256 = "1lhq9aalfdx40c4ymx1hihlld83g56732s9l68z6qqjl1jgvqwzp";
#     }) {system = "x86_64-linux";};
# in
{
  imports =
    [ 
      ./hardware/default.nix
      ./core/default.nix
      ./gui/default.nix
    ];

  # Wifi Driver Config
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];
  boot.initrd.kernelModules = ["8821au"];
 
  environment.systemPackages = with pkgs; [
      blueman
      cmake
      gnumake
      libtool

      xorg.xmodmap
      gcc
      
      openvpn
      networkmanager-openvpn
      networkmanagerapplet
      obs-studio
  ];
}

