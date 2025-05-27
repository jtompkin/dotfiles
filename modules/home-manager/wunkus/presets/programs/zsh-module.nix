{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.zsh;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.programs.zsh.enable = lib.mkEnableOption "Zsh preset configuration";
  options.wunkus.presets.programs.zsh.oh-my-zsh = lib.mkEnableOption "oh-my-zsh integration";
  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          cat = mkIf config.programs.bat.enable "bat --paging=never";
          fd = mkIf config.programs.fd.enable "fd --one-file-system";
          ls = "ls --color=tty --group-directories-first";
          l = "ls -lAhpv";
          la = "ls -lahpv";
          ll = "ls -lhpv";
          info = "info --vi-keys";
          ssh-vm = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          scp-vm = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          rebuild = "nixos-rebuild --flake github:jtompkin/dotfiles#nixos --use-remote-sudo switch";
          rebuild-local = "nixos-rebuild --flake '/home/josh/dotfiles#nixos' --use-remote-sudo switch";
          pkgdoc = "nix edit -f '<nixpkgs>'";
        };
        initContent =
          mkIf config.programs.bat.enable # bash
            ''
              eval "$(batpipe)"
              alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
            '';
        oh-my-zsh = mkIf cfg.oh-my-zsh {
          enable = true;
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
      direnv = mkIf cfg.oh-my-zsh {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
