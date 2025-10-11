{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.media;
in
{
  options.wunkus.profiles.media.enable = lib.mkEnableOption "media editing programs";
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.gimp3
      pkgs.inkscape
    ];
  };
}
