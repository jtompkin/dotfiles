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
    mornix.programs.goclacker.enable = mkDefault true;
    wunkus.presets = {
      programs = {
        zsh.enable = mkDefault true;
        tmux.enable = mkDefault true;
        tmux.minimal = false;
        neovim.enable = mkDefault true;
        shellExtras.enable = mkDefault true;
        sequoia = {
          enable = mkDefault true;
          config = {
            encrypt.profile = "rfc9580";
            key.generate.profile = "rfc9580";
          };
        };
        git.enable = mkDefault true;
      };
      services = {
        gpg-agent.enable = mkDefault true;
      };
    };
  };
}
