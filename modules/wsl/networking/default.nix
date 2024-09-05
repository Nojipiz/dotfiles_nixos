{
  config = {

    networking = {
      hostName = "OLap"; 
      networkmanager.enable = true; 
    };

    networking.firewall = {
      enable = true;
    };
  };
}
