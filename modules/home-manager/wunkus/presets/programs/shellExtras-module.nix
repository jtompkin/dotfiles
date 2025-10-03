{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.shellExtras;
  inherit (lib) mkDefault;
in
{
  options.wunkus.presets.programs.shellExtras.enable =
    lib.mkEnableOption "oh-my-posh, direnv, zoxide, bat, fzf, fd, ripgrep configuration";
  config = lib.mkIf cfg.enable {
    programs = {
      oh-my-posh = {
        enable = mkDefault true;
        settings = {
          version = 3;
          blocks = [
            {
              type = "prompt";
              alignment = "left";
              segments = [
                {
                  template = "{{ if .WSL }}WSL at {{ end }}{{.Icon}}";
                  foreground = "#26C6DA";
                  type = "os";
                  style = "plain";
                  properties = {
                    macos = "mac";
                  };
                }
                {
                  template = " {{ .UserName }}: ";
                  foreground = "#26C6DA";
                  type = "session";
                  style = "plain";
                }
                {
                  template = "{{ .Path }} ";
                  foreground = "lightGreen";
                  type = "path";
                  style = "plain";
                  properties = {
                    style = "unique";
                  };
                }
                {
                  template = "{{ .UpstreamIcon }} {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} ";
                  type = "git";
                  style = "plain";
                  properties = {
                    fetch_status = true;
                    fetch_upstream_icon = true;
                  };
                }
                {
                  template = "[ {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }}] ";
                  foreground = "#906cff";
                  type = "python";
                  style = "powerline";
                }
                {
                  template = "[ {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }}] ";
                  foreground = "#7FD5EA";
                  type = "go";
                  style = "powerline";
                }
                {
                  template = "❯ ";
                  foreground = "#FFD54F";
                  type = "text";
                  style = "plain";
                }
              ];
            }
          ];
        };
      };
      zoxide = {
        enable = mkDefault true;
        options = [
          "--cmd"
          "cd"
        ];
      };
      bat = {
        enable = mkDefault true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
          batpipe
        ];
      };
      zsh = lib.mkIf config.programs.zsh.enable {
        shellAliases = {
          cat = mkDefault "bat --paging=never";
          fd = mkDefault "fd --one-file-system";
          l = mkDefault "eza -la";
          lx = mkDefault "eza -lX";
        };
        shellGlobalAliases = {
          "--belp" = "--help 2>&1 | bat --language=help --style=plain";
        };
        initContent = ''
          eval "$(batpipe)"
        '';
        oh-my-zsh = {
          enable = mkDefault true;
          theme = mkDefault "gallifrey";
          plugins = [
            "git"
            "sudo"
            "direnv"
          ];
        };
        plugins = [
          {
            name = "vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          rec {
            name = "zsh-completion-sync";
            src = pkgs.fetchFromGitHub {
              owner = "BronzeDeer";
              repo = name;
              tag = "v0.3.3";
              hash = "sha256-GTW4nLVW1/09aXNnZJuKs12CoalzWGKB79VsQ2a2Av4=";
            };
            file = "${name}.plugin.zsh";
          }
        ];
      };
      direnv = {
        enable = mkDefault true;
        nix-direnv.enable = mkDefault true;
      };
      fzf = {
        enable = mkDefault true;
        changeDirWidgetCommand = mkDefault "";
      };
      eza = {
        enable = true;
        extraOptions = [
          "--group-directories-first"
          "--header"
          "--smart-group"
          "--git"
        ];
      };
      fastfetch.enable = mkDefault true;
      fd.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
    };
  };
}
