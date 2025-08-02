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
    mkOption
    types
    ;
  cfg = config.wunkus.presets.programs.hyprland;
in
{
  options = {
    wunkus.presets.programs.hyprland = {
      enable = mkEnableOption "Hyprland preset config";
      minimal = mkEnableOption "Hyprland minimal config";
      terminal = mkOption {
        type = types.str;
        default = "alacritty";
      };
      fileManager = mkOption {
        type = types.str;
        default = "thunar";
      };
      menu = mkOption {
        type = types.str;
        default = "bemenu-run";
      };
    };
  };
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = mkDefault true;
      systemd.enable = true;
      package = mkDefault null;
      settings = {
      };
    };
    programs.waybar = mkIf (!cfg.minimal) {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
    };
    services = mkIf (!cfg.minimal) {
      network-manager-applet.enable = mkDefault true;
      mako.enable = mkDefault true;
      hyprpaper.enable = mkDefault true;
    };
    wunkus.presets.programs = mkIf (!cfg.minimal) {
      bemenu.enable = true;
    };
  };
}
