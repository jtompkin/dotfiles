{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.discord;
in
{
  options.wunkus.presets.programs.discord = {
    enable = lib.mkEnableOption "discord preset config";
    basic = lib.mkEnableOption "default Discord client instead of Vencord";
    package = lib.mkPackageOption pkgs "discord" { };
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.discord.package = lib.mkIf (!cfg.basic) (
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
