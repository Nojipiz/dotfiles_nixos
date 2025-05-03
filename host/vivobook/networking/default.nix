{ pkgs , ...}:
{
  environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
  ];

  services.zerotierone = {
    enable = false;
    joinNetworks = [];
  };
  networking = {
    hostName = "OLap"; 
    networkmanager.enable = true; 
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 19000 ];
    allowedTCPPortRanges = [
      { from = 1000 ; to = 9000; }
    ];
    allowedUDPPortRanges = [
      { from = 19000; to = 20000; }
    ];
  };
}
