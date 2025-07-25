{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher

    # Wine packages
    wineWowPackages.waylandFull
    winetricks

    # For steering wheels
    oversteer
  ];

  # Logitech G29 config
  hardware.new-lg4ff.enable = true;
  services.udev.packages = with pkgs; [ oversteer ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
