{config, pkgs , ...}:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];
  boot.initrd.kernelModules = ["8821au"];

  console = {
    font = "Lat2-Terminus16";
  };

 
  environment.systemPackages = with pkgs; [
    blueman
    cmake
    gnumake
    libtool
    gcc
      
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
    obs-studio

    alacritty
    pcmanfm
    anydesk
    slack
  ];

 # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Time and language settings.
  time.timeZone = "America/Bogota";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "C.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "es_CO.UTF-8";
    };
  };

  # Nix's Properties
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.sudo.wheelNeedsPassword = false;

  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
