{pkgs, ...}:
{
  home.packages = with pkgs; [
    zed-editor
  ];

  home.file.".config/zed" = {
    source = config/zed;
  };
}
