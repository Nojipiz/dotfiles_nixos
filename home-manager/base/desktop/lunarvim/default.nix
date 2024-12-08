{ pkgs, ... }:
{

  home.packages = [
   pkgs.xclip
  ];

  home.file.".config/lvim/config.lua" = {
    source = lvim/config.lua;
  };

  home.file.".config/lvim/lua" = {
    source = lvim/lua;
  };
}
