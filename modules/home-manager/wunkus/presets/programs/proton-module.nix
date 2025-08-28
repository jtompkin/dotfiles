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
    wayland.windowManager.hyprland = mkIf config.wunkus.presets.programs.hyprland.enable {
      settings = {
        exec-once = [
          "uwsm app -- ${lib.getExe pkgs.protonvpn-gui} --start-minimized"
        ];
      };
    };
  };
}
