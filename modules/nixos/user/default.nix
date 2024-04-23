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
    SBT_OPTS = "-Xmx5G -XX:+UseG1GC -XX:+IgnoreUnrecognizedVMOptions -XX:MaxPermSize=4G -Xss4M -Duser.timezone=GMT";
    JAVA_OPTS = "-Xmx10G -XX:+UseG1GC -XX:+UseStringDeduplication";
    COMPOSER_MEMORY_LIMIT = "-1";
    #LD_LIBRARY_PATH = nixpkgs.zlib/lib;
  };
}
