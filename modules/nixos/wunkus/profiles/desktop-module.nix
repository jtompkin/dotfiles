{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.profiles.desktop;
in
{
  options = {
    wunkus.profiles.desktop = {
      enable = mkEnableOption "desktop system configuration";
    };
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = mkDefault true;
      withUWSM = mkDefault true;
      xwayland.enable = mkDefault true;
    };
  };
}
