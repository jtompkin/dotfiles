{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.services.spotify;
  spotify-playerExe = lib.getExe config.programs.spotify-player.package;
in
{
  options = {
    wunkus.presets.services.spotify = {
      enable = mkEnableOption "spotify configuration";
      launcher = lib.mkPackageOption pkgs "spotify-launcher" { };
      notifier = lib.mkPackageOption pkgs "spotify-notification" { };
    };
  };
  config = mkIf cfg.enable {
    wunkus.presets.services.spotify = {
      launcher = mkDefault (
        pkgs.writeShellScriptBin "spotify-launcher" ''
          ${lib.getExe config.programs.kitty.package} ${spotify-playerExe}
        ''
      );
      # Stolen from: https://docs.spotifyd.rs/advanced/hooks.html
      notifier =
        let
          jqExe = lib.getExe pkgs.jq;
        in
        mkDefault (
          pkgs.writeShellScriptBin "spotify-notification" ''
            client_id=$(cat ${config.age.secrets.spotify-client-id-01.path})
            secret=$(cat ${config.age.secrets.spotify-secret-01.path})
            if [ "$PLAYER_EVENT" = "start" ]; then
              token=$(curl -s -X 'POST' -u $client_id:$secret -d grant_type=client_credentials https://accounts.spotify.com/api/token | ${jqExe} '.access_token' | cut -d\" -f2)
              RESULT=$?
              if [ $RESULT -eq 0 ]; then
                curl -s -X 'GET' https://api.spotify.com/v1/tracks/$TRACK_ID -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization:\"Bearer $token\"" | ${jqExe} '.name, .artists[].name, .album.name, .album.release_date, .track_number, .album.total_tracks' | xargs printf "\"Playing '%s' from '%s' (album: '%s' in %s (%s/%s))\"" | xargs notify-send --expire-time=7000 --app-name=spotifyd Spotify
              else
                echo "Cannot get token."
              fi
            elif [ "$PLAYER_EVENT" = "stop" ]; then
              token=$(curl -s -X 'POST' -u $client_id:$secret -d grant_type=client_credentials https://accounts.spotify.com/api/token | ${jqExe} '.access_token' | cut -d\" -f2)
              RESULT=$?
              if [ $RESULT -eq 0 ]; then
                curl -s -X 'GET' https://api.spotify.com/v1/tracks/$TRACK_ID -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization:\"Bearer $token\"" | ${jqExe} '.name, .artists[].name, .album.name, .album.release_date, .track_number, .album.total_tracks' | xargs printf "\"Stoping music (Last song: '%s' from '%s' (album: '%s' in %s (%s/%s)))\"" | xargs notify-send --expire-time=7000 --app-name=spotifyd Spotify
              else
                echo "Cannot get token."
              fi
            else
              echo "Unkown event."
            fi
          ''
        );
    };
    home.packages = [
      cfg.launcher
    ];
    xdg.desktopEntries = {
      spotify-player = {
        name = "Spotify (terminal)";
        genericName = "Music Player";
        type = "Application";
        terminal = true;
        exec = "${spotify-playerExe}";
        icon = ./data/spotify/spotify.png;
        categories = [
          "AudioVideo"
          "Audio"
          "Music"
        ];
        settings = {
          Keywords = "music;spotify";
          DBusActivatable = "false";
        };
      };
    };
    services.spotifyd = {
      enable = mkDefault true;
      settings = {
        global = {
          device_name = "NixOS ixodes";
          onevent = lib.getExe cfg.notifier;
        };
      };
    };
    programs.spotify-player = {
      enable = mkDefault true;
      # settings = lib.importTOML ./data/app.toml // {
      settings = {
        theme = mkDefault "dracula";
        client_port = mkDefault 8080;
        login_redirect_uri = mkDefault "http://127.0.0.1:8989/login";
        playback_format = mkDefault ''
          {status} {track} • {artists} {liked}
          {album}
          {metadata}'';
        playback_metadata_fields = [
          "repeat"
          "shuffle"
          "volume"
          "device"
        ];
        notify_timeout_in_secs = mkDefault 0;
        tracks_playback_limit = mkDefault 50;
        app_refresh_duration_in_ms = mkDefault 32;
        playback_refresh_duration_in_ms = mkDefault 0;
        page_size_in_rows = mkDefault 20;
        play_icon = mkDefault "▶";
        pause_icon = mkDefault "▌▌";
        liked_icon = mkDefault "♥";
        border_type = mkDefault "Plain";
        progress_bar_type = mkDefault "Rectangle";
        cover_img_length = mkDefault 9;
        cover_img_width = mkDefault 5;
        enable_media_control = mkDefault true;
        enable_cover_image_cache = mkDefault true;
        notify_streaming_only = mkDefault false;
        seek_duration_secs = mkDefault 5;
        sort_artist_albums_by_type = mkDefault false;
        cover_img_scale = mkDefault 1.0;
        enable_streaming = mkDefault "Never";
        enable_notify = mkDefault false;
        default_device = mkDefault config.services.spotifyd.settings.global.device_name;
        notify_format = {
          summary = mkDefault "{track} • {artists}";
          body = mkDefault "{album}";
        };
        layout = {
          playback_window_position = mkDefault "Top";
          playback_window_height = mkDefault 6;
          library = {
            playlist_percent = mkDefault 40;
            album_percent = mkDefault 40;
          };
        };
        # TODO: remove userid dependency once agenix gets their shit together
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
