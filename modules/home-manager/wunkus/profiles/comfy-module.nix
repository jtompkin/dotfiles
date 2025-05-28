{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.comfy;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.comfy.enable = lib.mkEnableOption "comfy home-manager profile";
  config = mkIf cfg.enable {
    home.packages = [ pkgs.dust ];
    programs.goclacker.enable = mkDefault true;
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        tmux.enable = mkDefault true;
        tmux.minimal = false;
        neovim.enable = mkDefault true;
        shellExtras.enable = mkDefault true;
        git.enable = mkDefault true;
      };
      services = {
        gpg-agent.enable = mkDefault true;
      };
    };
  };
}
