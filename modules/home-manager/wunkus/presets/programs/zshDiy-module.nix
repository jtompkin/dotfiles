{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.zshDiy;
  zimfw-completion = pkgs.fetchFromGitHub {
    owner = "zimfw";
    repo = "completion";
    rev = "efc94ced311dd181835ccfd3f08ecb422c8465b2";
    hash = "sha256-8V3c3lFEyfJZuWNifMY+6Lw4qCXtBsX4I6ClLlCivSE=";
  };
in
{
  options.wunkus.presets.programs.zshDiy = {
    enable = lib.mkEnableOption "zsh DIY plugin management";
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.zim.enable = lib.mkForce false;
    home.sessionVariables = {
      EZA_COLORS = "da=1;34:gm=1;34:Su=1;34";
      ZVM_LAZY_KEYBINDINGS = "false";
      ZVM_INIT_MODE = "sourcing";
      ZVM_VI_SURROUND_BINDKEY = "s-prefix";
    };
    programs = {
      zsh = {
        oh-my-zsh.enable = lib.mkForce false;
        defaultKeymap = "viins";
        historySubstringSearch = {
          enable = mkDefault true;
          searchUpKey = [ "^K" ];
          searchDownKey = [ "^J" ];
        };
        enableCompletion = false;
        autosuggestion.enable = mkDefault true;
        syntaxHighlighting.enable = mkDefault true;
        zsh-abbr = {
          enable = mkDefault true;
          abbreviations = lib.mkMerge [
            (lib.mkIf config.programs.eza.enable (
              let
                lsCmd = "eza --group-directories-first";
                lsLongCmd = "${lsCmd} -l --git --header --smart-group --git";
              in
              {
                ls = lsCmd;
                "${lsCmd} " = "${lsCmd} -a";
                l = lsLongCmd;
                "${lsLongCmd} " = "${lsLongCmd} -a";
                "${lsLongCmd} r" = "${lsLongCmd} -T";
                "${lsLongCmd} x" = "${lsLongCmd} -sextension";
                "${lsLongCmd} k" = "${lsLongCmd} -ssize";
                "${lsLongCmd} t" = "${lsLongCmd} -smodified";
                "${lsLongCmd} c" = "${lsLongCmd} -schanged";
              }
            ))
            {
              g = "git";
              "git a" = "git add";
              "git b" = "git branch";
              "git b x" = "git branch --delete";
              "git b X" = "git branch -D";
              "git c" = "git commit";
              "git c m" = "git commit --message";
              "git co" = "git checkout";
              "git w" = "git status";
              "git y" = "git switch";
              "git y c" = "git switch create";
            }
          ];
        };
        initContent = lib.mkMerge [
          (lib.mkBefore ''
            fpath+="${pkgs.just}/share/zsh/site-functions"
            fpath+="${pkgs.uv}/share/zsh/site-functions"
          '')
          (lib.mkIf config.programs.zsh.zsh-abbr.enable ''
            bindkey ' ' abbr-expand-and-insert
          '')
          (lib.mkIf config.programs.zsh.historySubstringSearch.enable ''
            bindkey -M vicmd 'k' history-substring-search-up
            bindkey -M vicmd 'j' history-substring-search-down
          '')
          ''
            bindkey '^L' vi-forward-char
          ''
        ];
        plugins = lib.mkMerge [
          [
            {
              name = "zsh-vi-mode";
              src = pkgs.zsh-vi-mode;
              file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
            }
            {
              name = "zimfw-environment";
              file = "init.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "zimfw";
                repo = "environment";
                rev = "d4bceaa3da89cd819843334dba1a5bf7dc137e14";
                hash = "sha256-B8Cki4uCcSce0xewZ91P9wCpA5+x/AlT1IwC+HVs6OI=";
              };
            }
            {
              name = "zimfw-input";
              file = "init.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "zimfw";
                repo = "input";
                rev = "da6b1cccac5e56104088acc2d66e181f3317192a";
                hash = "sha256-QWyQpOxU3+P2+EGTkzt9HdEwhVnBa3yPwv7JA2o5YIQ=";
              };
            }
            {
              name = "zimfw-termtitle";
              file = "init.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "zimfw";
                repo = "termtitle";
                rev = "96aff3e49bc0c8665b20226b06517a8ee7452914";
                hash = "sha256-OQEIL12nqruTZzWGMv7p2Lx1EADOv2dr71xAE2aHww4=";
              };
            }
            {
              name = "zsh-completions";
              # TODO: remove once updated in nixpkgs
              src = pkgs.zsh-completions.overrideAttrs {
                version = "2025-12-16";
                src = pkgs.fetchFromGitHub {
                  owner = "zsh-users";
                  repo = "zsh-completions";
                  rev = "6ceec63710a422c0b5e5c6eecb7ddeff3506a7a3";
                  hash = "sha256-EUnR/iIzNE9/ba4O+dPu68JJtgoMIQAjhNcy/Ib6XTg=";
                };
              };
            }
            # {
            #   name = "zsh-completion-sync";
            #   src = pkgs.zsh-completion-sync;
            #   file = "share/zsh-completion-sync/zsh-completion-sync.plugin.zsh";
            # }
          ]
          (lib.mkAfter [
            {
              name = "zimfw-completion";
              src = zimfw-completion;
              file = "init.zsh";
            }
          ])
        ];
      };
      fzf.enableZshIntegration = true;
      direnv.enableZshIntegration = true;
      zoxide.enableZshIntegration = true;
      eza.enableZshIntegration = false;
    };
  };
}
