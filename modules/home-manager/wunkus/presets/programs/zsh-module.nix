{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.zsh;
  inherit (lib) mkDefault;
in
{
  options.wunkus.presets.programs.zsh.enable = lib.mkEnableOption "Zsh preset configuration";
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = mkDefault true;
        dotDir = "${config.xdg.configHome}/zsh";
        shellAliases = {
          ssh-vm = mkDefault "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
          scp-vm = mkDefault "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
        };
      };
    };
  };
}
