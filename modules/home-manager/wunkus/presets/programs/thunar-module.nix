{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.thunar;
  package = cfg.package.override { thunarPlugins = cfg.plugins; };
in
{
  options.wunkus.presets.programs.thunar = {
    enable = lib.mkEnableOption "Thunar preset configuration";
    package = lib.mkPackageOption pkgs "thunar" { };
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.thunar-vcs-plugin
        pkgs.thunar-archive-plugin
        pkgs.thunar-media-tags-plugin
        pkgs.thunar-volman
      ];
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      package
      pkgs.xfconf
    ];
    systemd.user.packages = [
      cfg.package
    ];
    dbus.packages = [
      package
      pkgs.xfconf
    ];
    xdg.terminal-exec.enable = mkDefault true;
  };
}
