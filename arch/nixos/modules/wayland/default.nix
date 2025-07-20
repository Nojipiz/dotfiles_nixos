{ pkgs, ... }:

{
  services.libinput.enable = true;
  services.displayManager.defaultSession = "none+sway";
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
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
    waybar
    vlc
    feh
    rofi
    nwg-displays
    wlsunset
  ];
}
