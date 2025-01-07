{ pkgs, ... }: {
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true;  # default shell on catalina
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 1;
  ids.gids.nixbld = 350; 
  security.pam.enableSudoTouchIdAuth = true;

  home-manager.backupFileExtension = "backup";
  nix.configureBuildUsers = true;
  nix.settings.build-users-group = "nixbld";
  nix.useDaemon = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "Hello there!";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  fonts.packages = with pkgs; [
    roboto
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];
}
