{ lib, pkgs, ... }:

let
  mod = "Mod4";
in {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    
    config = rec {
      modifier = mod;

      window.border = 0;
      gaps = {
        inner = 2;
        outer = 2;
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
      };

      modes = lib.mkOptionDefault {
        resize = {
          "Escape" = "mode default";
          "Return" = "mode default";
          "${mod}+r" = "mode default";
        };
      };

      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ~/Images/Wallpapers/morado.jpg";
          always = true;
          notification = false;
        }
      ];
      assigns = {
        "1" = [{ class = "Chromium"; }];
        "2" = [{ class = "jetbrains-studio"; }];
      };
    };
  };
}
