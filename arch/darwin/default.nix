{ pkgs, ... }: {
  environment.systemPackages =
    [ 
      pkgs.vim
      pkgs.direnv
      pkgs.sshs
      pkgs.glow
      pkgs.nushell
      pkgs.carapace
    ];
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true;  # default shell on catalina
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
  security.pam.enableSudoTouchIdAuth = true;

  users.users.nojipiz.home = "/Users/nojipiz";
  home-manager.backupFileExtension = "backup";
  nix.configureBuildUsers = true;
  nix.settings.build-users-group = "nixbld";
  nix.useDaemon = true;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "David Orlando";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  homebrew.enable = true;
  homebrew.casks = [
    "google-chrome"
  ];
  homebrew.brews = [
    "imagemagick"
  ];
}
