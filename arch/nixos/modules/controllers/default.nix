{ pkgs, ... }:
{
  programs.adb.enable = true;
  programs.light.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    audio.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  hardware = {
    bluetooth.enable = true;
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    blueman # Bluetooth
    pavucontrol # Sound control
  ];

  # For battery power management
  services.upower.enable = true;
  services.tuned.enable = true;
}
