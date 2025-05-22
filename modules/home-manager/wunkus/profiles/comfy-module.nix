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
  options.wunkus.profiles.comfy.enable = lib.mkEnableOption "Comfy home-manager";
  config = mkIf cfg.enable {
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        zsh.oh-my-zsh = mkDefault true;
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
