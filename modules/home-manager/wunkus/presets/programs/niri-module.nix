{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.wunkus.presets.programs.niri;
in
{
  options.wunkus.presets.programs.niri = {
    enable = mkEnableOption "Niri preset config";
    defaultApps = mkOption {
      type = types.attrsOf (types.submodule config.lib.dotfiles.types.defaultApp);
      default = { };
    };
    wallpaperDir = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };
  config = mkIf cfg.enable {
    wunkus.presets.programs.niri.defaultApps = {
      terminal.package =
        {
          alacritty = config.programs.alacritty.package;
          foot = config.programs.foot.package;
          kitty = config.programs.kitty.package;
        }
        .${cfg.defaultApps.terminal.name};
      fileManager.package =
        {
          thunar = pkgs.xfce.thunar.override {
            thunarPlugins = with pkgs.xfce; [
              thunar-vcs-plugin
              thunar-archive-plugin
            ];
          };
        }
        .${cfg.defaultApps.fileManager.name};
      appLauncher.package =
        {
          anyrun = config.programs.anyrun.package;
          fuzzel = config.programs.fuzzel.package;
        }
        .${cfg.defaultApps.appLauncher.name};
      screenShotter.package =
        {
          hyprshot = config.programs.hyprshot.package;
          flameshot = config.services.flameshot.package;
        }
        .${cfg.defaultApps.screenShotter.name};
      imageViewer.package =
        {
          feh = config.programs.feh.package;
        }
        .${cfg.defaultApps.imageViewer.name};
      videoPlayer.package =
        {
          mpv = config.programs.mpv.package;
        }
        .${cfg.defaultApps.videoPlayer.name};
    };
    programs = {
      niri = {
        enable = mkDefault true;
      };
    };
  };
}
