{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [ ethtool ];
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      pulseSupport = true;
    };
    config = {
      "settings" = { screenchange-reload = "true"; };

      "bar/mainBar" = {
        monitor-strict = false;
        override-redirect = false;
        fixed-center = "true";
        width = "100%";
        height = "20";
        background = "#000000";
        foreground = "#FFFFFF";
        module-margin-left = "0";
        module-margin-right = "0";

        font-0 = "Roboto:size=14;1";
        font-1 = "RobotoMono Nerd Font Mono:pixelsize=20;3";
        font-2 = "RobotoMono Nerd Font Mono:pixelsize=20;3";
      };
      "bar/top" = {
        "inherit" = "bar/mainBar";
        modules-left = "i3";
        modules-center = "date";
        modules-right =
          "volume network-wired network-wireless battery";
        tray-position = "right";
        tray-detached = false;
        tray-padding = "2";
        tray-background = "#000000";
      };

      "bar/bottom" = {
        "inherit" = "bar/mainBar";
        bottom = "true";
        modules-left = "memory cpu";
        modules-center = "window-title";
        modules-right =
          "vpn";
        tray-position = "right";
        tray-detached = false;
        tray-padding = "2";
        tray-background = "#000000";
      };

      "module/i3" = {
         type = "internal/i3";
         format = "<label-state> <label-mode>";
         index-sort = true;
         wrapping-scroll = false;
      };

      "module/window-title" = {
        type = "internal/xwindow";
        format = "<label>";
        label = "%title%";
        label-maxlen = "40";
        label-empty = "Desktop";
      };

      "module/network-wireless" = {
        type = "internal/network";
        interface = "wlp2s0";
        interval = "3.0";
        format-connected-prefix = " ";
        format-connected-background = "#000000";
        format-connected-foreground = "#FFFFFF";
        format-connected = "  <ramp-signal> <label-connected>  ";
        format-connected-underline= "#FFFFFF";
        label-connected = "";

        format-disconnected = " no wifi :( ";
        format-disconnected-background = "#000000";
        label-disconnected-foreground = "#000000";

        ramp-signal-0 = "    0%";
        ramp-signal-1 = "    25%";
        ramp-signal-2 = "    50%";
        ramp-signal-3 = "    75%";
        ramp-signal-4 = "    100%";
        ramp-signal-foreground = "#FFFFFF";
      };

      "module/network-wired" = {
        type = "internal/network";
        interval = "5.0";
        format-connected-underline = "#000000";
        format-connected-prefix = "";
        format-connected-prefix-foreground = "#FFFFFF";
        label-connected = "%local_ip%";
        format-disconnected = "no wired connection";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = "1";
        format = "<label>";
        format-prefix = "";
        format-prefix-font = "3";
        label = " %percentage%%";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = "1";
        format-prefix = "﬙";
        format-prefix-font = "3";
        label = " %gb_used%";
      };
      "module/volume" = {
        type = "internal/pulseaudio";
       #sink = alsa_output.pci-0000_05_00.6.analog-stereo
        master-soundcard = "hw:1";
        speaker-soundcard = "hw:1";
        headphone-soundcard = "hw:1";
        master-mixer = "Master";
        speaker-mixer = "Speaker";
        headphone-mixer = "Headphone";
        headphone-id = "9";
        mapped = true;
        format-muted-background = "#000000";
        format-volume-background = "#000000";
        format-volume = "   <ramp-volume>  <label-volume>  ";
        format-volume-prefix = " ";
        label-muted = " mute   ";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
      };

      "module/vpn" = {
        type = "custom/script";
        exec = "echo ";
        exec-if = "systemctl is-active --quiet wireguard-wg0";
        interval = 5;
      };

      "module/date" = {
        type = "internal/date";
        interval = "1";
        date = "%A %d %B";
        time = "at %I:%M %p";
        label = "%date% %time%";
        format-prefix = " ";
        format-prefix-foreground = "#AB71FD";
      };

      "module/temperature" = {
        type = "internal/temperature";
        thermal-zone = "0";
        warn-temperature = "80";

        format = "<ramp> <label>";
        format-warn = "<label-warn>";

        label = "%temperature-c%";
        label-warn = " %temperature-c%";
        label-warn-foreground = "#F00";
        units = true;

        ramp-0 = "";
        ramp-1 = "";
        ramp-2 = "";
        ramp-3 = "";
        ramp-4 = "";
        ramp-0-foreground = "#B6B99D";
        ramp-1-foreground = "#A0A57E";
        ramp-2-foreground = "#DEBC9C";
        ramp-3-foreground = "#D19485";
        ramp-4-foreground = "#C36561";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = "99";
        format-full-background = "#000000";
        format-charging-background = "#000000";
        format-charging = "<animation-charging> <label-charging>";
        format-charging-underline = "#000000";
        format-charging-suffix = "   ";
        format-discharging-background = "#000000";
        format-discharging = "<ramp-capacity> <label-discharging>  ";
        format-discharging-underline = "#000000";
        format-full = "";
        format-full-prefix-foreground = "#FFFFFF";
        ramp-capacity-0 = "";
        ramp-capacity-1 = "";
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";
        ramp-capacity-foreground = "#FFFFFF";
        ramp-capacity-font = 2;
        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-3 = "";
        animation-charging-4 = "";
        animation-charging-foreground = "#FFFFFF";
        animation-charging-framerate = 750;
      };


      "global/wm" = {
        margin-top = "5";
        margin-bottom = "5";
      };
    };
    script = "";
  };
}
