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
    wslClip = lib.mkEnableOption "WSL clipboard support for zsh-vi-mode";
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.cacheFile."zim/zimfw.zsh".source = "${pkgs.zimfw}/zimfw.zsh";
    home = {
      file."${config.programs.zsh.dotDir}/.zimrc" = {
        text = lib.concatMapStrings (plugin: "zmodule ${plugin}\n") cfg.plugins;
        onChange = "rm ${config.xdg.cacheHome}/zim/init.zsh";
      };
      sessionVariables =
        # zsh-vi-mode does not play nice with other plugin bindings without the fist two set
        lib.mkIf (lib.elem "jeffreytse/zsh-vi-mode" config.wunkus.presets.programs.zim.plugins) (
          {
            ZVM_LAZY_KEYBINDINGS = "false";
            ZVM_INIT_MODE = "sourcing";
            ZVM_VI_SURROUND_BINDKEY = "s-prefix";
            ZVM_SYSTEM_CLIPBOARD_ENABLED = "true";
          }
          // lib.optionalAttrs cfg.wslClip {
            ZVM_CLIPBOARD_COPY_CMD = "clip.exe";
            ZVM_CLIPBOARD_PASTE_CMD = "pwsh.exe -NoProfile -Command Get-Clipboard";
          }
        );
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
        oh-my-zsh.enable = lib.mkForce false;
        completionInit = "";
        defaultKeymap = "viins";
        initContent =
          lib.mkAfter # sh
            ''
              zstyle ':zim:zmodule' use 'degit'
              zstyle ':completion-sync:compinit:experimental:no-caching' enabled true
              zstyle ':completion-sync:compinit:experimental:fast-add' enabled true
              ZIM_CONFIG_FILE="${config.programs.zsh.dotDir}/.zimrc"
              ZIM_HOME="${config.xdg.cacheHome}/zim"
              if [[ ! -f ''${ZIM_HOME}/init.zsh ]] then
                source ''${ZIM_HOME}/zimfw.zsh init
              fi
              if [[ ! -n $(find ''${ZIM_HOME} -type f -mtime -1 -name .updated) ]] then # last update was more than 1 day ago
                print $'\E[33m'zimfw: Checking for plugin updates...
                if [[ -n $(source ''${ZIM_HOME}/zimfw.zsh check) ]] then # updates are available
                  print $'\E[33m'zimfw: Updating plugins...
                  source ''${ZIM_HOME}/zimfw.zsh update
                else
                  print $'\E[32m'zimfw: No updates available ':)'
                fi
                touch ''${ZIM_HOME}/.updated
              fi
              source ''${ZIM_HOME}/init.zsh
              zmodload -F zsh/terminfo +p:terminfo

              bindkey '^K' history-substring-search-up
              bindkey '^J' history-substring-search-down
              bindkey -M vicmd 'k' history-substring-search-up
              bindkey -M vicmd 'j' history-substring-search-down
              bindkey '^L' vi-forward-char
            '';
      };
      zoxide.enableZshIntegration = false;
      fzf.enableZshIntegration = false;
      eza.enableZshIntegration = false;
    };
  };
}
