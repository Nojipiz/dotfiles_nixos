{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TUI
    lazydocker
    lazygit

    skim
    starship
    jless
    ripgrep
    fd
    killall
    neovim-unwrapped
    neofetch
    git
    p7zip
    unzip
    wget
    btop
  ];
}
