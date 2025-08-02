{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.programs.waybar;
in
{
  options = {
    wunkus.presets.programs.waybar.enable = mkEnableOption "waybar preset config";
  };
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = mkDefault true;
      style = ./waybar/style.css;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [
            "hyprland/workspaces"
            "custom/right-arrow-dark"
            "hyprland/submap"
          ];
          modules-center = [
            "custom/left-arrow-dark"
            "clock#1"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "clock#2"
            "custom/right-arrow-dark"
            "custom/right-arrow-light"
            "clock#3"
            "custom/right-arrow-dark"
          ];
          modules-right = [
            "custom/left-arrow-dark"
            "wireplumber"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "memory"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "cpu"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "temperature"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "battery"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "tray"
          ];
          "custom/left-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/left-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "hyprland/workspaces" = {
            disable-scroll = true;
            format = "{icon}";
          };
          "hyprland/submap" = {
            format = " {}";
          };
          "clock#1" = {
            "format" = "{:%a}";
            "tooltip" = false;
          };
          "clock#2" = {
            "format" = "{:%H:%M}";
            "tooltip" = false;
          };
          "clock#3" = {
            "format" = "{:%m-%d}";
            "tooltip" = false;
          };
          "wireplumber" = {
            "format" = "{icon}  {volume:2}%";
            "format-muted" = "  {volume:2}%";
            "format-icons" = [
              ""
              ""
              ""
            ];
            "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          "memory" = {
            "interval" = 5;
            "format" = "Mem {}%";
            "tooltip-format" = "{used:0.1f}G / {total:0.1f}G\n{swapUsed:0.1f}G / {swapTotal:0.1f}G";
            "on-click" = "alacritty -e htop";
          };
          "cpu" = {
            "interval" = 5;
            "format" = "CPU {usage:2}%";
            "on-click" = "alacritty -e htop";
          };
          "temperature" = {
            "critical-threshold" = 80;
            "format-critical" = "{temperatureC}°C ";
            "format" = "{temperatureC}°C";
            "on-click" = "rog-control-center";
          };
          "battery" = {
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon}  {capacity}%";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "network" = {
            "max-length" = 50;
            "format" = "{ifname}";
            "format-wifi" = " ";
            "format-ethernet" = "{ipaddr}/{cidr} 󰊗";
            "format-disconnected" = " ";
            "tooltip-format" = "{ifname} via {gwaddr} 󰊗";
            "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
            "tooltip-format-ethernet" = "{ifname} ";
            "tooltip-format-disconnected" = "disconnected";
          };
          "tray" = {
            "icon-size" = 16;
          };
        };
      };
    };
  };
}
