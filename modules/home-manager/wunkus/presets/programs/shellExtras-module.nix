{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.shellExtras;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.programs.shellExtras.enable =
    lib.mkEnableOption "oh-my-posh, direnv, zoxide, bat, fzf, fd, ripgrep configuration";
  config = mkIf cfg.enable {
    programs = {
      oh-my-posh = {
        enable = mkDefault true;
        settings = builtins.fromTOML (builtins.readFile ./shellExtras/themes/my_space.omp.toml);
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
      zsh = mkIf config.programs.zsh.enable {
        shellAliases = {
          cat = mkDefault "bat --paging=never";
          fd = mkDefault "fd --one-file-system";
          l = mkDefault "eza -la";
          lx = mkDefault "eza -lX";
        };
        initContent = ''
          eval "$(batpipe)"
          alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
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
          {
            name = "zsh-completion-sync";
            src = pkgs.fetchFromGitHub {
              owner = "BronzeDeer";
              repo = "zsh-completion-sync";
              tag = "v0.3.1";
              hash = "sha256-XhZ7l8e2H1+W1oUkDrr8pQVPVbb3+1/wuu7MgXsTs+8=";
            };
            file = "zsh-completion-sync.plugin.zsh";
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
        enableZshIntegration = true;
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
