{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  uwsmPkg = lib.getExe pkgs.uwsm;
  spotify-playerExe = lib.getExe config.programs.spotify-player.package;
  cfg = config.wunkus.presets.programs.waybar;
in
{
  options = {
    wunkus.presets.programs.waybar.enable = mkEnableOption "waybar preset config";
  };
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = mkDefault true;
      style = mkDefault ./waybar/style.css;
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
            "custom/spotify-player"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "memory"
            # "custom/left-arrow-light"
            # "custom/left-arrow-dark"
            "cpu"
            # "custom/left-arrow-light"
            # "custom/left-arrow-dark"
            "temperature"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "battery"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            # "network"
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
          "custom/spotify-player" = {
            "exec" = "${
              pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/Alexays/Waybar/refs/tags/0.14.0/resources/custom_modules/mediaplayer.py";
                hash = "sha256-7Oq9cD4XKaHkrp2u0wDXNCGu2e44kZAUhmzu75WMR8E=";
                executable = true;
              }
            } --player spotify-player";
            "format" = "{icon} {text}";
            "format-icons" = {
              "spotify" = "";
              "default" = "🎵";
            };
            "on-click" = "${uwsmPkg} app -- ${lib.getExe pkgs.kitty} ${lib.getExe (
              pkgs.writeShellScriptBin "launch-spotify-daemon-and-player" ''
                if pgrep spotify_player >/dev/null; then
                  ${spotify-playerExe}
                else
                  ${spotify-playerExe} --daemon && ${spotify-playerExe}
                fi
              ''
            )}";
            "on-click-right" = "${spotify-playerExe} playback play-pause";
            "on-scroll-up" = "${spotify-playerExe} playback next";
            "on-scroll-down" = "${spotify-playerExe} playback previous";
          };
          "memory" = {
            "interval" = 5;
            "format" = "Mem {}%";
            "tooltip-format" = "{used:0.1f}G / {total:0.1f}G\n{swapUsed:0.1f}G / {swapTotal:0.1f}G";
            "on-click" = "${uwsmPkg} app -- alacritty -e ${lib.getExe pkgs.btop}";
          };
          "cpu" = {
            "interval" = 5;
            "format" = "CPU {usage:2}%";
            "on-click" = "${uwsmPkg} app -- alacritty -e ${lib.getExe pkgs.htop}";
          };
          "temperature" = {
            "critical-threshold" = 80;
            "format-critical" = "{temperatureC}°C ";
            "format" = "{temperatureC}°C";
            "on-click" = "${uwsmPkg} app -- rog-control-center";
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
