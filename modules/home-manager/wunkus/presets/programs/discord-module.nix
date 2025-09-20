{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wunkus.presets.programs.discord;
in
{
  options.wunkus.presets.programs.discord = {
    enable = mkEnableOption "discord preset config";
    basic = mkEnableOption "default Discord client instead of Vencord";
    package = lib.mkPackageOption pkgs "discord" { };
  };
  config = mkIf cfg.enable {
    wunkus.presets.programs.discord.package = mkIf (!cfg.basic) (
      pkgs.discord.override {
        withOpenASAR = true;
        withVencord = true;
      }
    );
    home.packages = [
      cfg.package
    ];
  };
}
