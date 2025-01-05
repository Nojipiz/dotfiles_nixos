{config, pkgs , ...}:
{
  config = {
    services.zerotierone = {
      enable = true;
      joinNetworks = [ ];
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
    };
  };

  environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
  ];
}
