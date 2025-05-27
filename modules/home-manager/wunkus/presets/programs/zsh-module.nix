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
          ls = "ls --color=tty --group-directories-first";
          l = "ls -lAhpv";
          la = "ls -lahpv";
          ll = "ls -lhpv";
          info = "info --vi-keys";
          ssh-vm = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          scp-vm = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          rebuild = "nixos-rebuild --flake 'github:jtompkin/dotfiles' --use-remote-sudo switch";
          rebuild-local = "nixos-rebuild --flake '${config.home.homeDirectory}/dotfiles' --use-remote-sudo switch";
          hm = "home-manager --flake 'github:jtompkin/dotfiles'";
          hm-local = "home-manager --flake '${config.home.homeDirectory}/dotfiles'";
          pkgdoc = "nix edit -f '<nixpkgs>'";
        };
      };
    };
  };
}
