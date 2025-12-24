{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    packer
    qemu
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Docker Settings
  virtualisation.docker = {
    enable = true;
    # Don't start containers on startup
    daemon.settings = {
      restart = "no";
    };
  };
}
