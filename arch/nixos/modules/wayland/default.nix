{ pkgs, ... }:

{
  services.libinput.enable = true;
  services.displayManager.defaultSession = "none+hyprland";
  programs.hyprland = {
    enable = true;
  };
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/hyprland";
        user = "nojipiz";
      };
      default_session = initial_session;
    };
  };

  fonts.packages = with pkgs; [
    roboto
    fira-code
    fira-code-symbols
    nerd-fonts.roboto-mono
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    vlc
    rofi
  ];
}
