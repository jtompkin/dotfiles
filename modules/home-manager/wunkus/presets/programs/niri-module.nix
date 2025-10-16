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
    mkMerge
    mkOption
    types
    ;
  cfg = config.wunkus.presets.programs.niri;
  isDefaultApp = type: name: cfg.defaultApps.${type}.name == name;
  getDefaltAppExe = type: lib.getExe cfg.defaultApps.${type}.package;
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
          walker = config.programs.walker.package;
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
        settings = {
          input = {
            keyboard = {
              xkb.options = "caps:swapescape";
              numlock = true;
            };
            warp-mouse-to-focus.enable = true;
            focus-follows-mouse = {
              enable = true;
              max-scroll-amount = "0%";
            };
          };
          layout = {
            focus-ring = { };
          };
          binds =
            with config.lib.niri.actions;
            let
              noctalia = spawn "noctalia-shell" "ipc" "call";
            in
            {
              "Mod+Return".action = spawn "${getDefaltAppExe "terminal"}";

              "Mod+D".action = noctalia "launcher" "toggle";
              "Mod+S".action = noctalia "sidePanel" "toggle";
              "Mod+P".action = noctalia "powerPanel" "toggle";
              "Mod+V".action = noctalia "launcher" "clipboard";
              "Mod+C".action = noctalia "launcher" "calculator";

              "XF86AudioRaiseVolume" = {
                action = noctalia "volume" "increase";
                allow-when-locked = true;
              };
              "XF86AudioLowerVolume" = {
                action = noctalia "volume" "decrease";
                allow-when-locked = true;
              };
              "XF86AudioMute" = {
                action = noctalia "volume" "muteOutput";
                allow-when-locked = true;
              };

              "XF86MonBrightnessUp" = {
                action = noctalia "brightness" "increase";
                allow-when-locked = true;
              };
              "XF86MonBrightnessDown" = {
                action = noctalia "brightness" "decrease";
                allow-when-locked = true;
              };

              "Mod+Shift+X".action = quit;
              "Mod+Shift+L".action = noctalia "lockScreen" "toggle";
              "Mod+Control+L".action = noctalia "idleInhibitor" "toggle";
            };
        };
      };
    };
  };
}
