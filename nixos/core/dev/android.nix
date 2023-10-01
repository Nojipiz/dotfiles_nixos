{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.android-tools
    gradle
  ];
}
