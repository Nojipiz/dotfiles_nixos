{ pkgs, ... }:
let
  opencodeConfig = import ./config.nix { inherit pkgs; };
in
{
  home.file.".config/opencode/opencode.json" = {
    text = builtins.toJSON opencodeConfig;
  };
}
