{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.tmux;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.programs.tmux.enable = lib.mkEnableOption "tmux preset configuration";
  options.wunkus.presets.programs.tmux.minimal = lib.mkEnableOption "minimal tmux configuration";
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      keyMode = mkDefault "vi";
      shell = mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
      extraConfig = # tmux
        ''
          set -g status-position top
          bind-key C-t set status
          set-option -a terminal-features 'xterm-256color:RGB'
        '';
      plugins =
        with pkgs.tmuxPlugins;
        mkIf (!cfg.minimal) [
          sensible
          pain-control
        ];
    };
  };
}
