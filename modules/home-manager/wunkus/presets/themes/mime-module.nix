{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.themes.mime;
in
{
  options.wunkus.presets.themes.mime = {
    enable = lib.mkEnableOption "xdg mime options";
  };
  config = lib.mkIf cfg.enable {
    programs.zathura.enable = mkDefault true;
    xdg.mimeApps = {
      enable = mkDefault true;
      defaultApplications = {
        "application/pdf" = [
          "org.pwmt.zathura.desktop"
        ];
      };
    };
  };
}
