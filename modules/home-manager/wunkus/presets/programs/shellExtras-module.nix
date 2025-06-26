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
        settings = mkDefault (builtins.fromTOML (builtins.readFile ./shellExtras/themes/my_space.omp.toml));
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
        };
        initContent = ''
          eval "$(batpipe)"
          alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
          command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
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
      fd.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
    };

  };
}
