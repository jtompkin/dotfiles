{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.zsh;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.programs.zsh.enable = lib.mkEnableOption "Zsh preset configuration";
  config = mkIf cfg.enable {
    programs = {
      zsh = {
        enable = mkDefault true;
        shellAliases = {
          ls = mkDefault "ls --color=tty --group-directories-first";
          l = mkDefault "ls -lAhpv";
          la = mkDefault "ls -lahpv";
          ll = mkDefault "ls -lhpv";
          info = mkDefault "info --vi-keys";
          ssh-vm = mkDefault "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          scp-vm = mkDefault "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          rebuild = mkDefault "nixos-rebuild --flake 'github:jtompkin/dotfiles' --use-remote-sudo switch";
          rebuild-local = mkDefault "nixos-rebuild --flake '${config.home.homeDirectory}/dotfiles' --use-remote-sudo switch";
          hm = mkDefault "home-manager --flake 'github:jtompkin/dotfiles'";
          hm-local = mkDefault "home-manager --flake '${config.home.homeDirectory}/dotfiles'";
          pkgdoc = mkDefault "nix edit -f '<nixpkgs>'";
        };
      };
    };
  };
}
