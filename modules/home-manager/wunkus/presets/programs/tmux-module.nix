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
    programs.tmux = lib.mkMerge [
      {
        enable = mkDefault true;
        keyMode = mkDefault "vi";
        clock24 = mkDefault true;
        terminal = "screen-256color";
        escapeTime = 0;
        shell = lib.mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
        extraConfig = lib.mkMerge [
          # tmux
          ''
            set -g status-position top
            bind-key C-t set status
            set-option -a terminal-features 'xterm-256color:RGB'
          ''
          (lib.mkIf (
            !(config.wunkus.presets.themes.stylish.enable || cfg.minimal)
            # This file is the same as produced by Stylix for its tmux target
          ) "source ${./data/tmux/base16-carbonfox.tmux}\n")
        ];
      }
      (lib.mkIf (!cfg.minimal) {
        sensibleOnTop = mkDefault true;
        plugins = [ pkgs.tmuxPlugins.pain-control ];
      })
    ];
  };
}
