{
  pkgs, ...
}:

let
  keyboardRemap = "${pkgs.writeText  "xkb-layout" ''
    remove shift = Shift_R
    keysym Shift_R = less greater
  ''}";

in {
  services.xserver = {
    enable = true;
    layout = "latam";
    desktopManager.xterm.enable = false;
    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${keyboardRemap}" ;
    };
    windowManager.i3.enable = true;
    libinput.enable = true;
  };

  fonts.fonts = with pkgs; [
    roboto
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  environment.systemPackages = with pkgs; [
    xdg-utils
    xorg.xmodmap
    redshift
    vlc
    feh 
    rofi
    polybarFull
  ];
}
