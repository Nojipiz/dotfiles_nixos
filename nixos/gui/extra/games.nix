{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 19000 3000 8090 ];
  };
}
