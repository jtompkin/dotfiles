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
  # TODO: remove once updated in nixpkgs
  zsh-completions-git = pkgs.zsh-completions.overrideAttrs (
    _: prevAttrs: {
      version = "2026-02-18";
      src = pkgs.fetchFromGitHub {
        inherit (prevAttrs.src) owner repo;
        rev = "4c84ebad534bdac3d2061db69082960c50856538";
        hash = "sha256-gSvuBYxe+L6ZdAViz4xyTkCGBKH1872bFdvBEAQYZKQ=";
      };
    }
  );
in
{
  options.wunkus.presets.programs.zshDiy = {
    enable = lib.mkEnableOption "zsh DIY plugin management";
    termtitle = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Set a custom terminal title";
    };
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
        setOptions = [ "NO_CLOBBER" ];
        enableCompletion = false;
        autosuggestion.enable = mkDefault true;
        syntaxHighlighting.enable = mkDefault true;
        zsh-abbr = {
          enable = mkDefault true;
          abbreviations = lib.mkMerge [
            (lib.mkIf config.programs.eza.enable (
              let
                lsCmd = "eza --group-directories-first";
                lsLongCmd = "${lsCmd} -lh --git --smart-group";
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
          globalAbbreviations = {
            "--H" = "--help 2>&1 | bat --language=help --style=plain";
          };
        };
        initContent = lib.mkMerge [
          (lib.mkIf config.programs.zsh.historySubstringSearch.enable ''
            bindkey -M vicmd 'k' history-substring-search-up
            bindkey -M vicmd 'j' history-substring-search-down
          '')
          (lib.mkIf (cfg.termtitle != null) ''
            zstyle ':zim:termtitle' format '${cfg.termtitle}'
          '')
          ''
            bindkey '^L' vi-forward-char
          ''
        ];
        plugins = lib.mkMerge [
          [
            {
              name = "zsh-vi-mode";
              src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
            }
            {
              name = "zsh-completions";
              src = "${zsh-completions-git}/share/zsh/site-functions";
            }
          ]
          (lib.mkIf (cfg.termtitle != null) [
            {
              name = "zimfw-termtitle";
              src = zshPlugins.zimfw-termtitle.package;
            }
          ])
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
