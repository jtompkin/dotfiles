{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.notCone;
in
{
  options.wunkus.presets.programs.notCone.enable =
    lib.mkEnableOption "mpv video player preset config";
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = lib.mkDefault true;
    };
  };
}
