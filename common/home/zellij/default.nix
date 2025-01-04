{
  programs.zellij.enable = true;

  home.file.".config/zellij/config.kdl" = {
    source = ./config.kdl;
  };
  home.file.".local/bin/project-sessionizer" = {
    source = ./project-sessionizer;
    executable = true;
  };
  home.file.".local/bin/fix-zellij" = {
    source = ./fix-zellij;
    executable = true;
  };
}
