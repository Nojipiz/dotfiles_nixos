{ lib, pkgs, ... }:

let 
  xd = "LOL";
in {
  programs.zellij.settings = {
    keybinds.clear-defaults=true;
  };
}
