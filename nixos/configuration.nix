{ config, pkgs, ... }:

let 
  _pkgsOld = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/4426104c8c900fbe048c33a0e6f68a006235ac50.tar.gz";
      sha256 = "1lhq9aalfdx40c4ymx1hihlld83g56732s9l68z6qqjl1jgvqwzp";
    }) {system = "x86_64-linux";};
in
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
  
  environment.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "chromium";
    TERMINAL = "alacritty";
    SBT_OPTS="-Xmx5G -XX:+UseConcMarkSweepGC -XX:+IgnoreUnrecognizedVMOptions -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=3G -Xss2M  -Duser.timezone=GMT";
    JAVA_OPTS="-Xmx5G";
    COMPOSER_MEMORY_LIMIT="-1";
  };

  environment.interactiveShellInit = ''
    alias graalvmjava=${pkgs.graalvm17-ce}/bin/java
  '';

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 19000 3000 ];
  };

  # Enable sound.
  sound.enable = true;
  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
  };

  programs.java = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      set fish_greeting
      alias g="lazygit"
      alias v="lvim"
      fish_add_path ~/mutable_node_modules/bin
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
      prismlauncher
      alacritty
      anydesk
      docker
      docker-compose
      lazydocker
      starship
      cargo
      nil

      # Android 
      unstable.android-tools
      unstable.android-studio
      gradle
      # Android 

      unstable.postman
      blueman
      cmake
      gnumake
      libtool

      # Scala Utilities
      scalafmt
      unstable.sbt
      unstable.coursier
      unstable.metals
      postgresql
      confluent-platform
      # Scala Utilities

      xdg-utils
      redshift
      feh
      xorg.xmodmap
      rofi
      polybarFull
      ripgrep
      fd
      killall
      lazygit
      pcmanfm
      neovim-unwrapped
      gcc
      chromium
      mako
      freshfetch
      git
      jdk17_headless
      graalvm17-ce
      p7zip
      unzip
      xclip
      zellij
      wget
      vlc
      openvpn
      networkmanager-openvpn
      networkmanagerapplet
      obs-studio
      nodejs
  ];
}

