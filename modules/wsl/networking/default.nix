{
  # imports = [ ./vpn.nix ];

  config = {
    networking = {
      hostName = "OLap"; 
      networkmanager.enable = true; 
    };
  };
}
