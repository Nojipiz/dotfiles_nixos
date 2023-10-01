{ pkgs, ... }:

{
  programs.java = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    jdk17_headless
    graalvm17-ce
  ];
}
