{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher

    # Wine packages
    wineWowPackages.waylandFull
    winetricks
    # (heroic.override{ extraPkgs = pkgs: [ pkgs.gamescope ]; })

    # For steering wheels
    # oversteer
  ];

  # Logitech G29 config
  # hardware.new-lg4ff.enable = true;
  services.udev.packages = with pkgs; [
    # oversteer

    # Enable them if VIA is required.
    # qmk-udev-rules
    # via
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    # extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  # programs.gamescope.enable = true;
  # programs.gamemode.enable = true;
}
