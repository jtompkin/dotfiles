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
  cfg = config.wunkus.presets.programs.proton;
in
{
  options = {
    wunkus.presets.programs.proton.enable = mkEnableOption "various Proton apps";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.protonvpn-gui ];
    wayland.windowManager.hyprland.settings.exec-once =
      lib.optional config.wunkus.presets.programs.hyprland.enable "uwsm app -- ${lib.getExe pkgs.protonvpn-gui} --start-minimized";
  };
}
