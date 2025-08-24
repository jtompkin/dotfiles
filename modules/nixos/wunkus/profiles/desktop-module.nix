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
      displayManager = {
        enable = mkEnableOption "display manager system configuration";
      };
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
      pkgs.sddm-astronaut
      # pkgs.tor-browser
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
      displayManager.sddm = mkIf cfg.displayManager.enable {
        enable = mkDefault true;
        package = pkgs.kdePackages.sddm;
        wayland.enable = mkDefault true;
        autoNumlock = mkDefault true;
        extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        theme = "sddm-astronaut-theme";
      };
    };
  };
}
