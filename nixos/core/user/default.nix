{ pkgs, ... }:

{
  # User base properties
  users = {
    defaultUserShell = pkgs.fish;
    users.nojipiz = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker"];
      initialPassword = "password";
    };
  };
}
