{ pkgs, ... }:
let
  allowBareAndArgs = commands:
    builtins.foldl' (allowed: command: allowed // { "${command}" = "allow"; "${command} *" = "allow"; }) { } commands;

  askByDefault = {
    "*" = "ask";
  };

  versionControl = {
    "git commit *" = "deny";
    "git push *" = "deny";
  } // allowBareAndArgs [ "git" ];

  contentSearch = allowBareAndArgs [ "grep" "rg" ];

  directoryListing = {
    "pwd" = "allow";
  } // allowBareAndArgs [ "ls" "dir" "vdir" "tree" "find" "fd" "eza" "exa" "lsd" ];

  fileInspection = allowBareAndArgs [ "cat" "head" "tail" "less" "more" "file" "stat" "wc" "du" "realpath" "readlink" "which" ];

  scalaBuildTool = allowBareAndArgs [ "sbt" ];

  readOnlyBash = askByDefault // versionControl // contentSearch // directoryListing // fileInspection;

  buildBash = readOnlyBash // scalaBuildTool;

  filesystemReads = {
    "read" = "allow";
    "glob" = "allow";
    "grep" = "allow";
    "external_directory" = {
      "*" = "allow";
    };
  };

  buildPermission = filesystemReads // {
    "bash" = buildBash;
  };

  planPermission = filesystemReads // {
    "bash" = readOnlyBash;
  };

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    "permission" = buildPermission;
    "agent" = {
      "build" = {
        "permission" = buildPermission;
      };
      "plan" = {
        "permission" = planPermission;
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
      source = config/harness;
      recursive = true;
    };
    file.".config/opencode/opencode.json" = {
      text = builtins.toJSON opencodeConfig;
    };
    packages = with pkgs; [
      unstable.opencode
      # For ui-image-comparator skill
      imagemagick
    ];
  };
}
