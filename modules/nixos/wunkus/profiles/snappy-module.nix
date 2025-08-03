{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wunkus.profiles.snappy;
in
{
  options = {
    wunkus.profiles.snappy.enable = mkEnableOption "snapper config";
  };

  config = mkIf cfg.enable {
    services.snapper.configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = config.wunkus.settings.username;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
}
