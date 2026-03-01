{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pcmanfm
    fastfetch
    btop
    nvtopPackages.full
    anydesk
    slack
  ];
}
