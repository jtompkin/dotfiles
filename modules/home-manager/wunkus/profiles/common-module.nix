{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.common;
  settings = config.wunkus.settings;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.common.enable = lib.mkEnableOption "Common home-manager";
  config = mkIf cfg.enable {
    home = {
      username = settings.username;
      homeDirectory =
        if pkgs.stdenv.isDarwin then "/Users/${settings.username}" else "/home/${settings.username}";
    };
    programs.home-manager.enable = mkDefault true;
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        tmux.enable = mkDefault true;
      };
    };
  };
}
