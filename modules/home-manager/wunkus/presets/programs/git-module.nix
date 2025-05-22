{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.git;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.programs.git.enable = lib.mkEnableOption "git preset configuration";
  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        delta.enable = mkDefault true;
        userName = mkDefault "jtompkin";
        userEmail = mkDefault "jtompkin-dev@pm.me";
        extraConfig.init.defaultBranch = mkDefault "main";
        signing = mkIf (config.programs.git.signing.key != null) {
          signByDefault = mkDefault true;
        };
      };
    };
  };
}
