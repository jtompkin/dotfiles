{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  inherit (config.mornix.programs) zshPlugins;
  cfg = config.wunkus.presets.programs.zshDiy;
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
              "git branch x" = "git branch --delete";
              "git branch X" = "git branch -D";
              "git c" = "git commit";
              "git commit m" = "git commit --message";
              "git o" = "git checkout";
              "git w" = "git status";
              "git y" = "git switch";
              "git switch c" = "git switch --create";
              n = "nix";
              "nix s" = "nix shell";
              "nix r" = "nix repl";
              "nix d" = "nix develop";
            }
          ];
        };
        initContent = lib.mkMerge [
          (lib.mkBefore ''
            fpath+=(
              "${pkgs.just}/share/zsh/site-functions"
              "${pkgs.uv}/share/zsh/site-functions"
            )
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
              src = zshPlugins.zimfw-environment.package;
            }
            {
              name = "zimfw-termtitle";
              src = zshPlugins.zimfw-termtitle.package;
            }
            {
              name = "zsh-completions";
              # TODO: remove once updated in nixpkgs
              src = pkgs.zsh-completions.overrideAttrs (
                _: prevAttrs: {
                  version = "2025-12-16";
                  src = pkgs.fetchFromGitHub {
                    inherit (prevAttrs.src) owner repo;
                    rev = "727876e7f688cff5c8fb6bf0495cb41b381ce01b";
                    hash = "sha256-Pd7OVDuhi2U27q2Hk6cXOweEpZR6SXgKUbA1H/Z4TSE=";
                  };
                }
              );
            }
          ]
          (lib.mkAfter [
            {
              name = "zimfw-completion";
              src = zshPlugins.zimfw-completion.package;
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
