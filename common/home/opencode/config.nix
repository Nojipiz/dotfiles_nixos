{ pkgs, ... }:
{
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
        "--headless"
        "--executable-path"
        "${pkgs.chromium}/bin/chromium"
      ];
      "enabled" = true;
    };
  };
}
