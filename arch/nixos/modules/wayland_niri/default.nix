{ pkgs, ... }:

{
  # Enabling niri
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.libinput.enable = true;
  services.displayManager.defaultSession = "none+niri";
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
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
    xwayland-satellite
  ];
}
