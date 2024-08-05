{ config, lib, pkgs, ...}:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true"] ;} );
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
    settings = {
      bottomBar = {
        layer = "top";
        position = "bottom";
        modules-left = [ "memory" "cpu" ];
        modules-center = [ ];
        modules-right = [ ];

        "cpu" = { "format" = "<span color='#b4befe'> </span>{usage}%"; };
        "memory" = {
          "interval" = 1;
          "format" = "<span color='#b4befe'> </span>{used:0.1f}G/{total:0.1f}G";
        };
      };

      topBar = {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "bluetooth" "battery" ];

        "sway/workspaces" = {
          "format" = "{icon}";
          "all-outputs" = true;
          "disable-scroll" = true;
        };

        "clock" = {
          "format" = "<span color='#b4befe'> </span>{:%H:%M}";
          "tooltip" = true;
          "tooltip-format" = "{:%Y-%m-%d %a}";
          "on-click-middle" = "exec default_wallpaper";
          "on-click-right" = "exec wallpaper_random";
        };

        "pulseaudio"= {
          "format" = "<span color='#b4befe'>{icon}</span> {volume}%";
          "format-muted" = "";
          "tooltip" = false;
          "format-icons" = {
            "headphone" = "";
            "default" = ["" "" "󰕾" "󰕾" "󰕾" "" "" ""];
          };
          "scroll-step" = 1;
          "on-click" = "pavucontrol";
        };
        "bluetooth" = {
          "format" = "<span color='#b4befe'></span> {status}";
          "format-disabled" = "";
          "format-connected" = "<span color='#b4befe'></span> {num_connections}";
          "tooltip-format" = "{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}   {device_address}";
        };
        "network" = {
          "interface" = "wlp3s0";
          "format" = "{ifname}";
          "format-wifi" = "<span color='#b4befe'> </span>{essid}";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "format-disconnected" = "<span color='#b4befe'>󰖪 </span>No Network";
          "tooltip" = false;
        };
        "battery" = {
          "format" = "<span color='#b4befe'>{icon} </span> {capacity}%";
          "format-icons" =  ["" "" "" "" ""];
          "format-charging" = "<span color='#b4befe'> </span> {capacity}%";
          "tooltip" = false;
        };
      };
    };

    style = ''
      * {
        border: none;
        font-family: 'Fira Code', 'Symbols Nerd Font Mono';
        font-size: 16px;
        font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
        min-height: 12px;
      }

      window#waybar {
        background: transparent;
      }

      #clock, #pulseaudio, #bluetooth, #network, #battery, #cpu, #memory, #workspaces {
        border-radius: 7px;
        background-color: #11111b;
        color: #cdd6f4;
        padding: 1px 10px;
        margin: 3px 5px;
      }

      #workspaces {
        color: #b4befe;
        padding: 1px 0;
      }

      #workspaces button.focused{
        color: #cdd6f4;
      }

      #clock {
        margin-right: 0;
      }
  '';
  };
}
