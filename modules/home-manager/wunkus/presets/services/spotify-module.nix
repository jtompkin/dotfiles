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
    wunkus.presets.services.spotify.launcher = lib.mkPackageOption pkgs "spotify-launcher" { };
  };
  config = mkIf cfg.enable {
    wunkus.presets.services.spotify.launcher =
      let
        spotify-playerExe = lib.getExe config.programs.spotify-player.package;
      in
      mkDefault (
        pkgs.writeShellScriptBin "spotify-launcher" ''
          if pgrep spotify_player >/dev/null; then
            ${spotify-playerExe}
          else
            ${spotify-playerExe} --daemon && ${spotify-playerExe}
          fi
        ''
      );
    home.packages = [
      cfg.launcher
    ];
    programs.spotify-player = {
      enable = mkDefault true;
      settings = builtins.fromTOML (lib.readFile ./data/app.toml) // {
        cover_img_scale = mkDefault 1.0;
        enable_streaming = "DaemonOnly";
        notify_streaming_only = true;
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
