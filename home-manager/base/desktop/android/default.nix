{ lib, pkgs, ... }:

{
  home.file.".ideavimrc" = {
    source = ./ideavimrc;
  };
  programs.adb.enable = true;
}
