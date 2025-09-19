{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.vapor;
  inherit (lib) mkIf mkDefault;
in
{
  options = {
    wunkus.profiles.vapor = {
      enable = lib.mkEnableOption "steam config";
    };
  };
  config = mkIf cfg.enable {
    programs.steam = {
      enable = mkDefault true;
      remotePlay.openFirewall = mkDefault true;
      dedicatedServer.openFirewall = mkDefault true;
    };
  };
}
