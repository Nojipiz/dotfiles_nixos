{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    packer
    qemu
  ];

  # TODO: Dont' work on macos
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;
}
