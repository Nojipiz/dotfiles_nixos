{ lib, pkgs, ... }:

{
  home.file.".ideavimrc" = {
    source = ideavimrc;
  };
}
