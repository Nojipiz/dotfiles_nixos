{
  config = {
    programs.light.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    services.blueman.enable = true;
    sound.enable = true;
    hardware = {
      pulseaudio.enable = false;
      bluetooth.enable = true;
    };

    virtualisation.docker.enable = true;
  };
}
