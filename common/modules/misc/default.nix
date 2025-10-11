{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    fastfetch
    btop
    nvtopPackages.full
    anydesk
    slack
  ];
}
