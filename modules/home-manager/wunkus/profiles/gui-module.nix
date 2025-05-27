{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.gui;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.gui.enable = lib.mkEnableOption "gui home-manager profile";
  options.wunkus.profiles.gui.nixGL =
    lib.mkEnableOption "gui home-manager profile with nixGL support";
  config = mkIf cfg.enable {
  };
}
