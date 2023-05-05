{ config, pkgs, ... }:

let 
  pkgsOld = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/4426104c8c900fbe048c33a0e6f68a006235ac50.tar.gz";
      sha256 = "1lhq9aalfdx40c4ymx1hihlld83g56732s9l68z6qqjl1jgvqwzp";
    }) {system = "x86_64-linux";};
  php74 = pkgsOld.php74;
  composer = pkgsOld.php74Packages.composer;
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
	
  boot.kernelParams = ["i915.force_probe=46a6"];
  # boot.kernelPackages = pkgs.linuxPackages_6_1;

  networking.hostName = "OLap"; # Define your hostname.
  networking.wireless.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.

  time.timeZone = "America/Bogota";
  environment.sessionVariables = rec {
    EDITOR = "nvim";
    BROWSER = "chromium";
    TERMINAL = "alacritty";
  };
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
      package = pkgs.i3-gaps;
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

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.nojipiz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker"];
    initialPassword = "password";
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    docker
    starship
    unstable.android-studio
    blueman
    emacs28NativeComp
    cmake
    gnumake
    libtool
    mariadb
    unstable.metals
    unstable.coursier
    unstable.sbt
    illum
    xdg-utils
    xorg.xmodmap
    acpilight
    rofi
    polybarFull
    ripgrep
    fd
    killall
    lazygit
    pcmanfm
    unstable.neovim-unwrapped
    gcc
    chromium
    mako
    freshfetch
    git
    jdk17_headless
    p7zip
    wl-clipboard
    wget
    #networkmanager-openvpn
    #networkmanagerapplet
    openvpn
    php74
    composer
    nodejs
  ];

  fonts.fonts = with pkgs; [
    roboto
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
    emacs-all-the-icons-fonts
  ];

  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.blueman.enable = true;

  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

