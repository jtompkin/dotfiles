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
    programs = {
      git = {
        enable = mkDefault true;
        ignores = [
          "Session.vim"
          ".direnv/"
          ".envrc"
        ];
        settings = {
          user = {
            name = mkDefault "jtompkin";
            email = mkDefault "jtompkin-dev@pm.me";
          };
          init.defaultBranch = mkDefault "main";
        };
        signing = lib.mkIf (config.programs.git.signing.key != null) {
          signByDefault = mkDefault true;
        };
      };
      delta = {
        enable = mkDefault true;
        enableGitIntegration = mkDefault true;
      };
    };
  };
}
