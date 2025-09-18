{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.programs.notCone;
in
{
  options = {
    wunkus.presets.programs.notCone = {
      enable = mkEnableOption "mpv video player preset config";
    };
  };
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = mkDefault true;
    };
  };
}
