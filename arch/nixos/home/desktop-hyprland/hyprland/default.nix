{ config, pkgs, ... }:

let
  mod = "SUPER";
  workspaceOne = "1";
  workspaceTwo = "2";
  workspaceThree = "3";
in {
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Monitor configuration (you may adjust to your actual monitor)
      monitor=,preferred,auto,1

      # Input config
      input {
        kb_layout=latam
      }

      general {
        gaps_in=2
        gaps_out=2
        border_size=0
        col.active_border=rgba(00000000)
        col.inactive_border=rgba(00000000)
      }

      decoration {
        rounding=0
        drop_shadow=no
      }

      animations {
        enabled=no
      }

      env = XCURSOR_SIZE,24

      # Autostart
      exec-once = ${pkgs.swaybg}/bin/swaybg -m fill -i ~/Images/wallpaper/base_wallpaper.png
      exec-once = ${pkgs.networkmanagerapplet}/bin/nm-applet

      # Window rules
      windowrulev2 = workspace ${workspaceOne},class:^(firefox)$
      windowrulev2 = workspace ${workspaceTwo},class:^(jetbrains-studio)$
      windowrulev2 = workspace ${workspaceTwo},class:^(zed)$

      # Keybindings
      bind = ${mod}, Return, exec, ${pkgs.alacritty}/bin/alacritty
      bind = ${mod} SHIFT, Q, killactive,
      bind = ${mod}, Z, exec, ${pkgs.rofi}/bin/rofi -show drun -show-icons
      bind = ${mod}, F, fullscreen,
      bind = ${mod} SHIFT, SPACE, togglefloating,
      bind = ${mod}, SPACE, togglesplit,
      bind = ${mod} SHIFT, R, exec, hyprctl reload
      bind = ${mod}, R, submap, resize
      bind = ${mod} SHIFT, E, exec, hyprctl dispatch exit

      # Focus movement
      bind = ${mod}, H, movefocus, l
      bind = ${mod}, J, movefocus, d
      bind = ${mod}, K, movefocus, u
      bind = ${mod}, L, movefocus, r

      # Move windows
      bind = ${mod} SHIFT, H, movewindow, l
      bind = ${mod} SHIFT, J, movewindow, d
      bind = ${mod} SHIFT, K, movewindow, u
      bind = ${mod} SHIFT, L, movewindow, r

      # Workspaces
      bind = ${mod}, 1, workspace, ${workspaceOne}
      bind = ${mod}, 2, workspace, ${workspaceTwo}
      bind = ${mod}, 3, workspace, ${workspaceThree}
      bind = ${mod} SHIFT, 1, movetoworkspace, ${workspaceOne}
      bind = ${mod} SHIFT, 2, movetoworkspace, ${workspaceTwo}
      bind = ${mod} SHIFT, 3, movetoworkspace, ${workspaceThree}

      # Brightness (using light)
      # bind = ,XF86MonBrightnessUp, exec, ${pkgs.light}/bin/light -A 10
      # bind = ,XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 10

      # Screenshot
      bind = ,Print, exec, ${pkgs.grim}/bin/grim ~/Images/$(date +%Y-%m-%d_%H:%M:%S).png

      # Resize mode (submap)
      submap = resize
      bind = ,Escape, submap, reset
      bind = ,Return, submap, reset
      bind = ${mod}, R, submap, reset
      bind = ,H, resizeactive, -20 0
      bind = ,L, resizeactive, 20 0
      bind = ,K, resizeactive, 0 -20
      bind = ,J, resizeactive, 0 20
      submap = reset
    '';
  };
}
