{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.zim;
in
{
  options.wunkus.presets.programs.zim = {
    enable = lib.mkEnableOption "Zim Zsh configuration manager prest config";
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.cacheFile."zim/zimfw.zsh".source = "${pkgs.zimfw}/zimfw.zsh";
    home.file."${config.programs.zsh.dotDir}/zimrc" = {
      text = lib.concatMapStrings (plugin: "zmodule ${plugin}\n") cfg.plugins;
      onChange = "rm ${config.xdg.cacheHome}/zim/init.zsh";
    };
    wunkus.presets.programs.zim.plugins = lib.mkMerge [
      (lib.mkBefore [
        "environment"
        "git"
        "input"
        "termtitle"
        "utility"
        "jeffreytse/zsh-vi-mode"
        "zsh-users/zsh-completions --fpath src"
      ])
      (lib.mkIf (!config.programs.starship.enable) [
        "duration-info"
        "git-info"
        "asciiship"
      ])
      (lib.mkIf config.programs.starship.enable [ "joke/zim-starship" ])
      (lib.mkIf config.programs.fzf.enable [ "fzf" ])
      (lib.mkIf config.programs.eza.enable (lib.mkOrder 1001 [ "exa" ]))
      (lib.mkIf config.programs.zoxide.enable [ "kiesman99/zim-zoxide" ])
      (lib.mkAfter [
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-history-substring-search"
        "zsh-users/zsh-autosuggestions"
        "BronzeDeer/zsh-completion-sync"
        "completion"
      ])
    ];
    programs = {
      zsh = {
        enable = mkDefault true;
        oh-my-zsh.enable = false;
        completionInit = "";
        initContent =
          lib.mkAfter # sh
            ''
              zstyle ':zim:zmodule' use 'degit'
              zstyle ':completion-sync:compinit:experimental:no-caching' enabled true
              zstyle ':completion-sync:compinit:experimental:fast-add' enabled true
              ZIM_CONFIG_FILE="${config.programs.zsh.dotDir}/zimrc"
              ZIM_HOME="${config.xdg.cacheHome}/zim"
              if [[ ! -f ''${ZIM_HOME}/init.zsh ]] then
                source ''${ZIM_HOME}/zimfw.zsh init
              fi
              source ''${ZIM_HOME}/init.zsh
              zmodload -F zsh/terminfo +p:terminfo
              for key ('^[[A' '^P' ''${terminfo[kcuu1]}) bindkey ''${key} history-substring-search-up
              for key ('^[[B' '^N' ''${terminfo[kcud1]}) bindkey ''${key} history-substring-search-down
              for key ('k') bindkey -M vicmd ''${key} history-substring-search-up
              for key ('j') bindkey -M vicmd ''${key} history-substring-search-down
            '';
      };
      zoxide.enableZshIntegration = false;
      fzf.enableZshIntegration = false;
      eza.enableZshIntegration = false;
    };
  };
}
