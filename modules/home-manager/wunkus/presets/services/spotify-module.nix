{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.services.spotify;
in
{
  options = {
    wunkus.presets.services.spotify.enable = mkEnableOption "spotify service configuration";
  };
  config = mkIf cfg.enable {
    programs.spotify-player = {
      enable = mkDefault true;
      package = mkDefault config.programs.spotify-player-git.package;
      settings = builtins.fromTOML (lib.readFile ./data/app.toml) // {
        cover_img_scale = mkDefault 1.0;
        client_id_command = mkIf (config.wunkus.settings.userid != null) {
          command = "cat";
          args = [
            "/run/user/${builtins.toString config.wunkus.settings.userid}/agenix/spotify-client-id-01"
          ];
        };
      };
    };
  };
}
