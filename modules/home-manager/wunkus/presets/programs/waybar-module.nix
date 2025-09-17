{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    ;
  uwsmExe = lib.getExe pkgs.uwsm;
  launchWithTerminal =
    extaArgs: package:
    "${uwsmExe} app -- ${lib.getExe pkgs.alacritty} ${extaArgs} -e ${lib.getExe package}";
  playerctlExe = lib.getExe config.services.playerctld.package;
  cfg = config.wunkus.presets.programs.waybar;
in
{
  options = {
    wunkus.presets.programs.waybar.enable = mkEnableOption "waybar preset config";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.meslo-lg ];
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
            # "cpu"
            # "temperature"
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
          "mpris" = {

          };
          "custom/spotify-player" = {
            "exec" = "${lib.getExe config.programs.waybar-mediaplayer.package} 2>/dev/null";
            "format" = "{icon}";
            "tooltip-format" = "{}";
            "escape" = true;
            "max-length" = 30;
            "return-type" = "json";
            "format-icons" = {
              "spotify" = "";
              "spotifyd" = "";
              "spotify_player" = "";
              "default" = "🎵";
            };
            "on-click" = "${uwsmExe} app -- ${lib.getExe config.wunkus.presets.services.spotify.launcher}";
            "on-click-right" = "${playerctlExe} play-pause";
            "on-click-middle" = "${lib.getExe pkgs.killall} spotify_player";
            "on-scroll-up" = "${playerctlExe} next";
            "on-scroll-down" = "${playerctlExe} previous";
          };
          "memory" = {
            "interval" = 5;
            "format" = "{}%";
            "tooltip-format" = "{used:0.1f}G / {total:0.1f}G\n{swapUsed:0.1f}G / {swapTotal:0.1f}G";
            "on-click" = launchWithTerminal "--class SystemInfo" pkgs.htop;
            "on-click-right" = launchWithTerminal "--class SystemInfo" pkgs.btop;
          };
          "cpu" = {
            "interval" = 5;
            "format" = "{usage:2}%";
            "on-click" = "${uwsmExe} app -- alacritty -e ${lib.getExe pkgs.htop}";
            "on-click-right" = "${uwsmExe} app -- alacritty -e ${lib.getExe pkgs.btop}";
          };
          "temperature" = {
            "critical-threshold" = 80;
            "format-critical" = "{temperatureC}°C ";
            "format" = "{temperatureC}°C";
            "on-click" = "${uwsmExe} app -- alacritty -e ${lib.getExe pkgs.htop}";
            "on-click-right" = "${uwsmExe} app -- alacritty -e ${lib.getExe pkgs.btop}";
          };
          "battery" = {
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon} {capacity}%";
            "on-click" = "${uwsmExe} app -- rog-control-center";
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
