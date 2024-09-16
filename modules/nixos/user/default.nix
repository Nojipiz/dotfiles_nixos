{ config, ... }:
{
  users = {
    users.nojipiz = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker" "vboxusers" "adbusers" "kvm"];
      initialPassword = "password";
    };
  };
 
  environment.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "chromium";
    TERMINAL = "alacritty";
    TERM = "xterm-color";
    SBT_OPTS = "-Xmx6G -XX:+UseG1GC -XX:+IgnoreUnrecognizedVMOptions -XX:MaxPermSize=4G -Xss4M -Duser.timezone=GMT";
    JAVA_OPTS = "-Xmx10G -XX:+UseG1GC -XX:+UseStringDeduplication";
    COMPOSER_MEMORY_LIMIT = "-1";
  };
}
