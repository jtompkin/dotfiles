{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.windy;
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    optional
    types
    ;
in
{
  options = {
    wunkus.profiles.windy = {
      enable = lib.mkEnableOption "bittorrent config";
      client =
        let
          clients = [
            "deluge"
            "qbittorrent"
          ];
        in
        mkOption {
          type = types.enum clients;
          default = lib.head clients;
        };
    };
  };
  config = mkIf cfg.enable {
    services.qbittorrent = mkIf (cfg.client == "qbittorrent") {
      enable = mkDefault true;
    };
    services.deluge = mkIf (cfg.client == "deluge") {
      enable = mkDefault true;
      web.enable = mkDefault true;
    };
    wunkus.profiles.ephemeral.extraDirectories =
      optional (cfg.client == "qbittorrent") config.services.qbittorrent.profileDir
      ++ optional (cfg.client == "deluge") config.services.deluge.dataDir;
    users.users.${config.wunkus.settings.username}.extraGroups = optional (
      cfg.client == "qbittorrent"
    ) "qbittorrent";
  };
}
