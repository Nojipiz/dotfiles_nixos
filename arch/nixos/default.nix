{
  console.font = "Lat2-Terminus16";
  # Nix's Properties
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    # allowUnsupportedSystem = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
