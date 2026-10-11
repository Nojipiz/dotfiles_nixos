{ pkgs, ... }:
let
  readOnlyBash = {
    "*" = "ask";
    "git *" = "allow";
    "git commit *" = "deny";
    "git push *" = "deny";
    "grep *" = "allow";
    "grep" = "allow";
    "rg *" = "allow";
    "rg" = "allow";
    # Directory listing and filesystem inspection (bare + args forms,
    # since "cmd *" does not match bare "cmd").
    "ls" = "allow";
    "ls *" = "allow";
    "dir" = "allow";
    "dir *" = "allow";
    "vdir" = "allow";
    "vdir *" = "allow";
    "pwd" = "allow";
    "tree" = "allow";
    "tree *" = "allow";
    "find *" = "allow";
    "find" = "allow";
    "fd *" = "allow";
    "fd" = "allow";
    "eza *" = "allow";
    "eza" = "allow";
    "exa *" = "allow";
    "exa" = "allow";
    "lsd *" = "allow";
    "lsd" = "allow";
    # Read-only file inspection.
    "cat *" = "allow";
    "cat" = "allow";
    "head *" = "allow";
    "head" = "allow";
    "tail *" = "allow";
    "tail" = "allow";
    "less *" = "allow";
    "less" = "allow";
    "more *" = "allow";
    "more" = "allow";
    "file *" = "allow";
    "file" = "allow";
    "stat *" = "allow";
    "stat" = "allow";
    "wc *" = "allow";
    "wc" = "allow";
    "du *" = "allow";
    "du" = "allow";
    "realpath *" = "allow";
    "realpath" = "allow";
    "readlink *" = "allow";
    "readlink" = "allow";
    "which *" = "allow";
    "which" = "allow";
  };
  readOnlyPermissions = {
    "read" = "allow";
    "glob" = "allow";
    "grep" = "allow";
    # Per https://opencode.ai/docs/permissions/#external-directories,
    # tools touching paths outside the workdir also need
    # external_directory. Object form with "*" matches the docs example
    # style ("~/secrets/**": "deny", "*": "allow").
    "external_directory" = {
      "*" = "allow";
    };
  };
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    "permission" = readOnlyPermissions // {
      "bash" = readOnlyBash;
    };
    "agent" = {
      "build" = {
        "permission" = readOnlyPermissions // {
          "bash" = readOnlyBash;
        };
      };
      "plan" = {
        # No "edit" override here: v1 plan already denies edits except
        # .opencode/plans/*.md (see `opencode debug agent plan`).
        # Overriding with edit deny would clobber that exception.
        "permission" = readOnlyPermissions // {
          "bash" = readOnlyBash;
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
