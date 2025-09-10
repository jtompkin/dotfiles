{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.gaimin;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.gaimin = {
    enable = lib.mkEnableOption "gaming home-manager profile";
    emulate.enable = lib.mkEnableOption "emulation program support";
  };
  config = mkIf cfg.enable {
    home.packages = lib.optional cfg.emulate.enable pkgs.punes-qt6;
  };
}
