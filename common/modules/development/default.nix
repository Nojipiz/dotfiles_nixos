{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # TUI
    lazydocker
    lazygit
    skim

    # Editors
    xclip
    neovim
    unstable.helix

    # Command line basics
    git
    p7zip
    unzip
    wget
    killall
    jless # json manipulation
    ripgrep
    websocat
    openssl
    # Building things
    cmake
    gnumake
    gcc-unwrapped
    libtool

    # Cache for Nix
    cachix
  ];
}
