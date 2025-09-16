{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.profiles.desktop;
  sddm-astronaut-custom =
    let
      imgStorePath = "${./data/desktop/MVIC_sunset_scan_of_Pluto.jpg}";
      backgroundsDir = "$out/share/sddm/themes/sddm-astronaut-theme/Backgrounds";
    in
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "Backgrounds/${baseNameOf imgStorePath}";
      };
    }).overrideAttrs
      (prevAttrs: {
        installPhase = prevAttrs.installPhase + ''
          chmod u+w ${backgroundsDir}
          cp ${imgStorePath} ${backgroundsDir}
        '';
      });
in
{
  options = {
    wunkus.profiles.desktop = {
      enable = mkEnableOption "desktop system configuration";
      spotify.enable = mkEnableOption "open ports required for Spotify";
      displayManager.enable = mkEnableOption "display manager system configuration";
      fileManager.enable = mkEnableOption "Thunar file manager configuration";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = mkDefault true;
        withUWSM = mkDefault true;
        xwayland.enable = mkDefault true;
      };
      thunar = mkIf cfg.fileManager.enable {
        enable = mkDefault true;
        plugins = with pkgs.xfce; [
          thunar-vcs-plugin
          thunar-archive-plugin
        ];
      };
    };
    security.pam.services.hyprlock = { };
    environment = {
      systemPackages = mkIf cfg.displayManager.enable [ sddm-astronaut-custom ];
      pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
    };
    security.rtkit.enable = mkDefault true;
    hardware.bluetooth.enable = mkDefault true;
    networking = mkIf cfg.spotify.enable {
      firewall = {
        allowedTCPPorts = [ 57621 ];
        allowedUDPPorts = [ 5353 ];
      };
      # Workaround for: https://github.com/Spotifyd/spotifyd/issues/1358
      hosts = {
        "0.0.0.0" = [ "apresolve.spotify.com" ];
      };
    };
    services = {
      blueman.enable = mkDefault true;
      gvfs.enable = mkDefault true;
      displayManager.sddm = mkIf cfg.displayManager.enable {
        enable = mkDefault true;
        package = mkDefault pkgs.kdePackages.sddm;
        wayland.enable = mkDefault true;
        autoNumlock = mkDefault true;
        extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        theme = mkDefault "sddm-astronaut-theme";
      };
    };
  };
}
