{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.sequoia;
in
{
  options.wunkus.presets.programs.sequoia = {
    enable = lib.mkEnableOption "Sequoia PGP configuration";
    package = lib.mkPackageOption pkgs "sequoia-sq" { };
    config = lib.mkOption {
      type = lib.types.nullOr lib.types.toml;
      default = null;
      description = "TOML config written to ~/.config/sequoia/sq/config.toml";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."sequoia/sq/config.toml" = lib.mkIf (cfg.config != null) {
      source = (pkgs.formats.toml { }).generate "sequoia-sq-config.toml" cfg.config;
    };
  };
}
