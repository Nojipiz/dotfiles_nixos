{
  pkgs, ...
}:

let
  keyboardRemap = "${pkgs.writeText  "xkb-layout" ''
    remove shift = Shift_R
    keysym Shift_R = less greater
  ''}";

in {
  services.libinput.enable = true;
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    xkb.layout = "latam";
    desktopManager.xterm.enable = false;
    displayManager = {
      sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${keyboardRemap}";
    };
    windowManager.i3.enable = true;
  };

  fonts.packages = with pkgs; [
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
