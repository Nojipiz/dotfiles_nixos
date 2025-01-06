{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    fastfetch
    btop
    fd
  ];
}
