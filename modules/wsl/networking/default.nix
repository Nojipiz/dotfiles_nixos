{ pkgs, ... }:
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

  environment.systemPackages = with pkgs; [
    wsl-vpnkit
  ];

  environment.shellAliases = {
    vpn-start = "sudo systemctl start wsl-vpnkit";
    vpn-stop = "sudo systemctl stop wsl-vpnkit";
    vpn-status = "systemctl status wsl-vpnkit";
  };

  systemd.services.wsl-vpnkit = {
    enable = true;
    description = "wsl-vpnkit";
    serviceConfig = {
      ExecStart = "${pkgs.unstable.wsl-vpnkit}/bin/wsl-vpnkit";
      Type = "idle";
      Restart = "always";
      KillMde = "mixed";
    };
  };
}
