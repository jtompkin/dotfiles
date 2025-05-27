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
  options.wunkus.profiles.common.enable = lib.mkEnableOption "common home-manager profile";
  config = mkIf cfg.enable {
    home = {
      username = settings.username;
      homeDirectory =
        if pkgs.stdenv.isDarwin then "/Users/${settings.username}" else "/home/${settings.username}";
    };
    xdg.configFile."home-manager/home.nix".text = ''
      abort "Do not use this configuration"
    '';
    programs.home-manager.enable = mkDefault true;
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        tmux.enable = mkDefault true;
        tmux.minimal = mkDefault true;
      };
    };
  };
}
