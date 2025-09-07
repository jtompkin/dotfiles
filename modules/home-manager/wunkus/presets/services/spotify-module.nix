{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.services.spotify;
in
{
  options = {
    wunkus.presets.services.spotify.enable = mkEnableOption "spotify configuration";
  };
  config = mkIf cfg.enable {
    home.packages =
      let
        spotify-playerExe = lib.getExe config.programs.spotify-player.package;
      in
      [
        (pkgs.writeShellScriptBin "launch-spotify-daemon-and-player" ''
          if pgrep spotify_player >/dev/null; then
            ${spotify-playerExe}
          else
            ${spotify-playerExe} --daemon && ${spotify-playerExe}
          fi
        '')
      ];
    programs.spotify-player = {
      enable = mkDefault true;
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
