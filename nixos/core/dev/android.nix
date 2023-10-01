{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.android-tools
    unstable.android-studio # TODO: Move from here
    gradle
  ];
}
