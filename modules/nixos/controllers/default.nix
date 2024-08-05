{
  config = {
    programs.light.enable = true;
    services.pipewire = {
      enable = false;
      # alsa.enable = true;
      # pulse.enable = true;
    };
    hardware = {
      pulseaudio.enable = true;
      bluetooth.enable = true;
    };
    services.blueman.enable = true;
    sound.enable = true;

    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.virtualbox.host.enable = true;
  };
}
