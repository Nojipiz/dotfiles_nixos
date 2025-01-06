{ pkgs, ... }:
{
  home.packages = with pkgs; [ 
    xclip
    neovim-unwrapped
  ];

  home.file.".config/lvim/config.lua" = {
    source = lvim/config.lua;
  };

  home.file.".config/lvim/lua" = {
    source = lvim/lua;
  };
}
