{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.themes.dark;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.themes.dark.enable = lib.mkEnableOption "dark theme";
  config = mkIf cfg.enable {
    gtk = {
      enable = mkDefault true;
      iconTheme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-icons;
      };
      theme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
    };
    qt = {
      enable = mkDefault true;
      platformTheme.name = mkDefault "gtk";
    };
  };
}
