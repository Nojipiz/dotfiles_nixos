{ niri-flake, config, pkgs, ... }:
{
  imports = [
    # Import the Niri Home Manager module
    niri-flake.homeModules.niri
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };
}
