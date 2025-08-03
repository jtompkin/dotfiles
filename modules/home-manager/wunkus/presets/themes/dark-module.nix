{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.themes.dark;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.themes.dark.enable = lib.mkEnableOption "dark theme";
  config = mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = mkDefault true;
      name = mkDefault "Bibata-Modern-Classic";
      package = mkDefault pkgs.bibata-cursors;
      size = mkDefault 14;
    };
    gtk = {
      enable = mkDefault true;
      iconTheme = {
        # name = mkDefault "Breeze-Dark";
        # package = mkDefault pkgs.kdePackages.breeze-icons;
        name = "Adwaita-Dark";
        package = pkgs.adwaita-icon-theme;
      };
      theme = {
        name = mkDefault "Breeze-Dark";
        package = mkDefault pkgs.kdePackages.breeze-gtk;
      };
    };
    qt = {
      enable = mkDefault true;
      platformTheme.name = mkDefault "gtk";
    };
  };
}
