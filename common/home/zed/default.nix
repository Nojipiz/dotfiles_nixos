{pkgs, ...}:
{
  home.packages = with pkgs; [
    unstable.zed-editor
  ];

  home.file.".config/zed" = {
    source = config/zed;
  };
}
