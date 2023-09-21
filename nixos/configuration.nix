{ config, pkgs, ... }:

let 
  pkgsOld = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/4426104c8c900fbe048c33a0e6f68a006235ac50.tar.gz";
      sha256 = "1lhq9aalfdx40c4ymx1hihlld83g56732s9l68z6qqjl1jgvqwzp";
    }) {system = "x86_64-linux";};
  php74 = pkgsOld.php74;
  php74Packages = pkgsOld.php74Packages;
  keyboardRemap = "${pkgs.writeText  "xkb-layout" ''
    remove shift = Shift_R
    keysym Shift_R = less greater
  ''}";
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
	
  # Force Intel to work
  # boot.kernelParams = ["i915.force_probe=46a6"];

  # Wifi Driver Config
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];
  boot.initrd.kernelModules = ["8821au"];

  networking.hostName = "OLap"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Bogota";
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

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "C.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "es_CO.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 19000 3000 ];
  };

  services.xserver = {
    enable = true;
    layout = "latam";
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${keyboardRemap}" ;
    };
    windowManager.i3 = {
      enable = true;
    };

    libinput = {
      enable = true;
    };
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

  programs.nix-index = {
    enableBashIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      set fish_greeting
      alias g="lazygit"
      alias v="lvim"
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  users.defaultUserShell = pkgs.fish;

  users.users.nojipiz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker"];
    initialPassword = "password";
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
      prismlauncher
      alacritty
      anydesk
      docker
      docker-compose
      lazydocker
      starship
      cargo

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
      # Temporal Hamachi
      logmein-hamachi
  ];

  fonts.fonts = with pkgs; [
    roboto
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  security.sudo.wheelNeedsPassword = false;

  programs.light.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.blueman.enable = true;

  services.logmein-hamachi.enable = true;

# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

