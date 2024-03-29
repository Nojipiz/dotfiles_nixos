{ config, ... }:
{
  users = {
    users.nojipiz = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker"];
      initialPassword = "password";
    };
  };
 
  environment.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "chromium";
    TERMINAL = "alacritty";
    SBT_OPTS="-Xmx5G -XX:+UseParallelGC -XX:+IgnoreUnrecognizedVMOptions -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=3G -Xss4M -Duser.timezone=GMT";
    JAVA_OPTS="-Xmx10G";
    COMPOSER_MEMORY_LIMIT="-1";
  };
}
