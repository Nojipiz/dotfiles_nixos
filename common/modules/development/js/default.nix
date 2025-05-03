{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bun
    pm2
  ];
}
