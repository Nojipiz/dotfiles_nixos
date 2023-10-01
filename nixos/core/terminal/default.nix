{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      set fish_greeting
      alias g="lazygit"
      alias v="lvim"
      fish_add_path ~/mutable_node_modules/bin
    '';
  };

  programs.nix-index.enableFishIntegration = true;

  console = {
    font = "Lat2-Terminus16";
  };

  # (TUI / terminal only) packages and tools
  environment.systemPackages = with pkgs; [
    lazydocker
    lazygit
    zellij
    starship
    jless
    ripgrep
    fd
    killall
    neovim-unwrapped
    freshfetch
    git
    p7zip
    wget
  ];
}
