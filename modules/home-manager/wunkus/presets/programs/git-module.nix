{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.git;
  inherit (lib) mkDefault;
in
{
  options.wunkus.presets.programs.git.enable = lib.mkEnableOption "git preset configuration";
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = mkDefault true;
      delta.enable = mkDefault true;
      userName = mkDefault "jtompkin";
      userEmail = mkDefault "jtompkin-dev@pm.me";
      extraConfig.init.defaultBranch = mkDefault "main";
      signing = lib.mkIf (config.programs.git.signing.key != null) {
        signByDefault = mkDefault true;
      };
    };
  };
}
