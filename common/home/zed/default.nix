{ pkgs, ... }:
{
  home = {
    file.".config/zed" = {
      source = config/zed;
    };
    packages = with pkgs; [
      unstable.zed-editor
    ];
  };
}
