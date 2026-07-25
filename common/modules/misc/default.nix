{ pkgs, ... }:
{
  # PCManFM support for autom mount usb
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    pcmanfm
    fastfetch
    btop
    nvtopPackages.full
    # anydesk
    slack
  ];
}
