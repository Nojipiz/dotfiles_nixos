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

    # AI
    opencode

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

    # Nix lsp
    nixd
    nil

    # Cache for Nix
    cachix
  ];
}
