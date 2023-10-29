{
  config = {
    networking = {
      hostName = "OLap"; 
      networkmanager.enable = true; 
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 19000 3000 8090 ];
    };
  };
}
