{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.programs.hyprland;
in
{
  options = {
    wunkus.presets.programs.hyprland = {
      enable = mkEnableOption "Hyprland preset configuration";
    };
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
