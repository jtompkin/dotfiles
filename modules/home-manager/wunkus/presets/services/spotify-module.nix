{
  config,
  lib,
  pkgs,
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
    home.packages = [ pkgs.spotify ];
    xdg.configFile."spotify/prefs".text = ''
      storage.size=3072
    '';
    # programs.spotify-player = {
    #   enable = mkDefault true;
    #   settings = {
    #     client_id = "1a84876bd85141fda6ee47d0bd82eb32";
    #   };
    # };
    # home.packages = [ pkgs.spotify-qt ];
    # services.librespot.enable = mkDefault true;
    # services.spotifyd = {
    # enable = mkDefault true;
    # settings = {
    # global = {
    # username = "jospamkin@gmail.com";
    # password = "iQ$SqB4ECTs3Bsbd";
    # device_name = "nix";
  };
  # audio = {
  #   backend = "pipe";
  # };
  # };
  # };
  # };
}
