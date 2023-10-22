{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.opentofu 
  ];
}
