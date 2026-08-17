{ pkgs, ... }:
let
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    "permission" = {
      "bash" = {
        "*" = "ask";
        "git *" = "allow";
        "git commit *" = "deny";
        "git push *" = "deny";
        "grep *" = "allow";
      };
    };
    "agent" = {
      "build" = {
        "permission" = {
          "bash" = {
            "*" = "ask";
            "git *" = "allow";
            "git commit *" = "deny";
            "git push *" = "deny";
            "grep *" = "allow";
          };
        };
      };
    };
    "mcp" = {
      "playwright" = {
        "type" = "local";
        "command" = [
          "bunx"
          "@playwright/mcp@latest"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
        ];
        "enabled" = false;
      };
    };
  };
in
{
  home = {
    file.".config/opencode" = {
      source = ./config/harness;
    };
    file.".config/opencode/opencode.json" = {
      text = builtins.toJSON opencodeConfig;
    };
    packages = with pkgs; [
      unstable.opencode
      imagemagick
    ];
  };
}
