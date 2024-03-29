{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      set fish_greeting
      alias g="lazygit"
      alias v="lvim"
      alias graalvmjava=${pkgs.graalvm-ce}/bin/java
      fish_add_path ~/mutable_node_modules/bin
      fish_add_path ~/.local/bin
    '';
  };

  programs.nix-index.enableFishIntegration = true;
}
