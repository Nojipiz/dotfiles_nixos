{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    deno
    pm2
  ];
}
