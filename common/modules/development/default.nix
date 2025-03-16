{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # TUI 
    lazydocker
    lazygit
    skim

    # Editors
    lunarvim 

    # Command line basics
    git
    p7zip
    unzip
    wget
    killall
    jless
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
