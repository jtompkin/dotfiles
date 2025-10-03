{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.proton;
in
{
  options = {
    wunkus.presets.programs.proton.enable = lib.mkEnableOption "various Proton apps";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.protonvpn-gui ];
    wayland.windowManager.hyprland.settings.exec-once =
      lib.optional config.wunkus.presets.programs.hyprland.enable "${lib.getExe pkgs.uwsm} app -- ${lib.getExe pkgs.protonvpn-gui} --start-minimized";
  };
}
