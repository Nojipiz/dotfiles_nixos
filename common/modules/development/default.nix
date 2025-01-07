{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # TUI 
    lazydocker
    lazygit
    lunarvim
    skim

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
