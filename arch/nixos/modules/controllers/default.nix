{ pkgs , ...}:
{
  programs.adb.enable = true;
  programs.light.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    blueman # Bluetooth 
    pavucontrol # Sound control
  ];
}
