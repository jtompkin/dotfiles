{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.forgejo;
  forgejoCfg = config.services.forgejo;
  srv = forgejoCfg.settings.server;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.forgejo.enable = lib.mkEnableOption "forgejo config";
  config = mkIf cfg.enable {
    wunkus.profiles.ephemeral.extraDirectories = [ "/var/lib/forgejo" ];
    services = {
      nginx = {
        enable = mkDefault true;
        virtualHosts.${forgejoCfg.settings.server.DOMAIN} = {
          # forceSSL = true;
          # enableACME = true;
          extraConfig = ''
            client_max_body_size 512M;
          '';
          locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
        };
      };
      forgejo = {
        enable = mkDefault true;
        database.type = mkDefault "postgres";
        lfs.enable = mkDefault true;
        settings = {
          server = {
            DOMAIN = mkDefault "localhost";
            ROOT_URL = mkDefault "http://${srv.DOMAIN}:${toString srv.HTTP_PORT}/";
            HTTP_PORT = mkDefault 3000;
          };
          # service.DISABLE_REGISTRATION = mkDefault true;
          actions = {
            ENABLED = mkDefault true;
            DEFAULT_ACTIONS_URL = mkDefault "github";
          };
        };
      };
    };
  };
}
