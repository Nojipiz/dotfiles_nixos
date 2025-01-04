{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # TUI 
    lazydocker
    lazygit
    skim

    # Command line basics
    git
    p7zip
    unzip
    wget
    killall
    jless
    ripgrep
  ];
}
