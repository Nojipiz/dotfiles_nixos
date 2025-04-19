{lib, pkgs, ...}:

let 
  mod = "Mod4";
  workspaceOne = "1: Web";
  workspaceTwo = "2: Code";
  workspaceThree = "3: Edit";
in {
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;

    extraConfig = ''
      set $opacity 1
      for_window [class=".*"] opacity $opacity
      for_window [app_id=".*"] opacity $opacity
    ''; 
    config = {
      modifier = mod;

      window = {
        border = 0;
        titlebar = false;
      };

      bars = [];

      gaps = {
        inner = 2;
        outer = 2;
      };

      input = {
        "*" = {
          xkb_layout = "latam";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+Shift+q" = "kill";
        "${mod}+z" = "exec ${pkgs.rofi}/bin/rofi -show drun -show-icons";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+r" = "mode \"resize\"";
        "${mod}+Shift+e" = "exec 'i3-nagbar -t warning -m 'Exit i3?' -B 'Of course' 'i3-msg exit''";

        # Windows Movement
        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";

        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        # Windows Movement Vim Style
        "${mod}+h" = "focus left";
        "${mod}+l" = "focus right";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Windows Split
        "${mod}+d" = "split h";
        "${mod}+v" = "split v";

        # Container Layout
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        # Container Focus
        "${mod}+a" = "focus parent";

        # Workspaces
        "${mod}+1" = "workspace ${workspaceOne}";
        "${mod}+2" = "workspace ${workspaceTwo}";
        "${mod}+3" = "workspace ${workspaceThree}";

        "${mod}+Shift+1" = "move container to workspace ${workspaceOne}";
        "${mod}+Shift+2" = "move container to workspace ${workspaceTwo}";
        "${mod}+Shift+3" = "move container to workspace ${workspaceThree}";

        # Audio and brigthness
        "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
        "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";

        # Screenshots
        "Print" = "exec ${pkgs.grim}/bin/grim ~/Images/`date +%Y-%m-%d_%H:%M:%S`.png";
      };

      modes = lib.mkOptionDefault {
        resize = {
          "Escape" = "mode default";
          "Return" = "mode default";
          "${mod}+r" = "mode default";
        };
      };
      defaultWorkspace = "workspace ${workspaceOne}";

      startup = [
        {
          command = "${pkgs.swaybg}/bin/swaybg -m fill -i ~/Images/wallpaper/base_wallpaper.png";
          always = true;
        }
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = false;
        }
        {
          command = "${pkgs.wlsunset}/bin/wlsunset -l 5.5403:-73.3614";
          always = false;
        }
      ];
      assigns = {
        "${workspaceOne}" = [{ class = "Chromium"; }];
        "${workspaceTwo}" = [{ class = "jetbrains-studio"; }];
      };
    };
  };
}
