{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.tmux;
  inherit (lib) mkDefault;
in
{
  options.wunkus.presets.programs.tmux = {
    enable = lib.mkEnableOption "tmux preset configuration";
    minimal = lib.mkEnableOption "minimal tmux configuration";
  };
  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = mkDefault true;
      keyMode = mkDefault "vi";
      shell = lib.mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
      extraConfig = # tmux
        ''
          set -g status-position top
          set -g status-bg "#4E9BEC"
          bind-key C-t set status
          set-option -a terminal-features 'xterm-256color:RGB'
        '';
      plugins = lib.mkIf (!cfg.minimal) [
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.pain-control
      ];
    };
  };
}
