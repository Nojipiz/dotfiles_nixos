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

  xdg.portal = pkgs.lib.mkForce{
    enable = false;
    extraPortals = [ ];
  };

  fonts.packages = with pkgs; [
    roboto
    fira-code
    fira-code-symbols
    nerd-fonts.roboto-mono
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-wlr
    waybar
    vlc
    feh
    rofi
    nwg-displays
    wlsunset
  ];
}
