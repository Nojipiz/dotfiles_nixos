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
      { from = 30000 ; to = 46000; }
      { from = 1000 ; to = 4000; }
      { from = 8000; to = 9000; }
      ];
    };
  };
}
