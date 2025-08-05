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
    environment.systemPackages = [
      pkgs.vivaldi
      pkgs.tor-browser
    ];
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
    security.rtkit.enable = mkDefault true;
    hardware.bluetooth.enable = mkDefault true;
    services = {
      blueman.enable = mkDefault true;
      gvfs.enable = mkDefault true;
    };
  };
}
