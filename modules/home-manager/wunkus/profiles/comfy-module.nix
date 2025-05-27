{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.common;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.comfy.enable = lib.mkEnableOption "comfy home-manager profile";
  config = mkIf cfg.enable {
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        tmux.enable = mkDefault true;
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
