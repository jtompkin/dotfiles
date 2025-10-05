{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.zsh;
  inherit (lib) mkDefault mkOverride;
in
{
  options.wunkus.presets.programs.zsh.enable = lib.mkEnableOption "Zsh preset configuration";
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = mkDefault true;
        dotDir = "${config.xdg.configHome}/zsh";
        shellAliases = {
          # l = mkOverride 1001 "ls -lAhpv";
          # ls = mkOverride 1001 "ls --color=tty --group-directories-first";
          # la = mkOverride 1001 "ls -lahpv";
          # ll = mkOverride 1001 "ls -lhpv";
          # info = mkDefault "info --vi-keys";
          ssh-vm = mkDefault "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          scp-vm = mkDefault "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          rebuild = mkDefault "nixos-rebuild --flake 'github:jtompkin/dotfiles/main' --use-remote-sudo switch";
          rebuild-local = mkDefault "nixos-rebuild --flake '${config.home.homeDirectory}/dotfiles' --use-remote-sudo switch";
          hm = mkDefault "home-manager --flake 'github:jtompkin/dotfiles/main'";
          hm-local = mkDefault "home-manager --flake '${config.home.homeDirectory}/dotfiles'";
          pkgdoc = mkDefault "nix edit -f '<nixpkgs>'";
        };
      };
    };
  };
}
