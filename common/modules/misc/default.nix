{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    fastfetch
    btop
    nvtopPackages.nvidia
    anydesk
    slack
  ];
}
