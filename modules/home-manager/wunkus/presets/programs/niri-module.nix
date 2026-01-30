{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.niri;
in
{
  options.wunkus.presets.programs.niri = {
    enable = lib.mkEnableOption "Niri preset config";
    noctalia.enable = lib.mkEnableOption "Noctalia-shell for Niri";
    defaultApps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule config.lib.dotfiles.types.defaultApp);
      default = { };
    };
    wallpaperDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        wunkus.presets.programs = {
          niri.defaultApps = {
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
          kitty = lib.mkIf (cfg.defaultApps.terminal.name == "kitty") {
            enable = mkDefault true;
          };
          thunar = lib.mkIf (cfg.defaultApps.fileManager.name == "thunar") {
            enable = mkDefault true;
            plugins = [
              pkgs.thunar-vcs-plugin
              pkgs.thunar-archive-plugin
              pkgs.thunar-media-tags-plugin
              pkgs.thunar-volman
            ];
          };
        };
        programs = {
          niri = {
            enable = mkDefault true;
            package = mkDefault pkgs.niri-patched;
            settings = {
              binds =
                let
                  genNumberBinds =
                    mod: action:
                    lib.genAttrs' (lib.range 1 9) (n: {
                      name = "${mod}+${toString n}";
                      value.action.${action} = n;
                    });
                  noctaliaCall =
                    command:
                    [
                      "noctalia-shell"
                      "ipc"
                      "call"
                    ]
                    ++ (if builtins.isList command then command else lib.splitString " " command);
                in
                {
                  "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
                  "Mod+Return" = {
                    action.spawn = lib.getExe cfg.defaultApps.terminal.package;
                    hotkey-overlay.title = "Open terminal: ${cfg.defaultApps.terminal.name}";
                  };
                  "Mod+D" = {
                    action.spawn = lib.getExe cfg.defaultApps.appLauncher.package;
                    hotkey-overlay.title = "Run an application: ${cfg.defaultApps.appLauncher.name}";
                  };
                  "Mod+O" = {
                    action.toggle-overview = [ ];
                    repeat = false;
                  };
                  "Mod+Q" = {
                    action.close-window = [ ];
                    repeat = false;
                  };

                  "Mod+H".action.focus-column-left = [ ];
                  "Mod+J".action.focus-window-down = [ ];
                  "Mod+K".action.focus-window-up = [ ];
                  "Mod+L".action.focus-column-right = [ ];
                  "Mod+F".action.fullscreen-window = [ ];
                  "Mod+Shift+F".action.maximize-column = [ ];
                  "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
                  "Mod+C".action.center-column = [ ];
                  "Mod+Ctrl+C".action.center-visible-columns = [ ];

                  "Mod+Shift+H".action.move-column-left = [ ];
                  "Mod+Shift+J".action.move-window-down = [ ];
                  "Mod+Shift+K".action.move-window-up = [ ];
                  "Mod+Shift+L".action.move-column-right = [ ];

                  "Mod+Ctrl+H".action.move-column-to-monitor-left = [ ];
                  "Mod+Ctrl+J".action.move-column-to-monitor-down = [ ];
                  "Mod+Ctrl+K".action.move-column-to-monitor-up = [ ];
                  "Mod+Ctrl+L".action.move-column-to-monitor-right = [ ];

                  "Mod+U".action.focus-workspace-up = [ ];
                  "Mod+I".action.focus-workspace-down = [ ];
                  "Mod+Shift+U".action.move-column-to-workspace-up = [ ];
                  "Mod+Shift+I".action.move-column-to-workspace-down = [ ];
                  "Mod+Ctrl+U".action.move-workspace-up = [ ];
                  "Mod+Ctrl+I".action.move-workspace-down = [ ];

                  "Mod+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.focus-workspace-down = [ ];
                  };
                  "Mod+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.focus-workspace-up = [ ];
                  };
                  "Mod+Ctrl+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-down = [ ];
                  };
                  "Mod+Ctrl+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-up = [ ];
                  };
                  "Mod+Ctrl+Shift+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.move-column-right = [ ];
                  };
                  "Mod+Ctrl+Shift+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.move-column-left = [ ];
                  };

                  "Mod+Tab".action.focus-workspace-previous = [ ];

                  "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
                  "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

                  "Mod+Comma".action.consume-window-into-column = [ ];
                  "Mod+Period".action.expel-window-from-column = [ ];

                  "Mod+R".action.switch-preset-column-width = [ ];
                  "Mod+Shift+R".action.switch-preset-window-height = [ ];
                  "Mod+Ctrl+R".action.reset-window-height = [ ];

                  "Mod+V".action.toggle-window-floating = [ ];
                  "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

                  "Mod+W".action.toggle-column-tabbed-display = [ ];

                  "Mod+Space".action.switch-layout = "next";
                  "Mod+Shift+Space".action.switch-layout = "prev";

                  "Print".action.screenshot = [ ];
                  "Ctrl+Print".action.screenshot-screen = [ ];
                  "Mod+Print".action.screenshot-window = [ ];

                  "Mod+Escape" = {
                    allow-inhibiting = false;
                    action.toggle-keyboard-shortcuts-inhibit = [ ];
                  };

                  "Mod+Shift+P".action.power-off-monitors = [ ];
                  "Mod+Shift+E".action.quit = [ ];
                  "Ctrl+Alt+Delete".action.quit = [ { skip-confirmation = true; } ];
                }
                // genNumberBinds "Mod" "focus-workspace"
                // genNumberBinds "Mod+Ctrl" "move-column-to-workspace"
                // (lib.optionalAttrs cfg.noctalia.enable {
                  "Mod+D" = {
                    action.spawn = noctaliaCall "launcher toggle";
                    hotkey-overlay.title = "Noctalia: Open/Close application launcher";
                  };
                  "Mod+Shift+D" = {
                    action.spawn = noctaliaCall "launcher command";
                    hotkey-overlay.title = "Noctalia: Run shell command";
                  };
                  "Mod+S" = {
                    action.spawn = noctaliaCall "controlCenter toggle";
                    hotkey-overlay.title = "Noctalia: Open/Close control center";
                  };
                  "Mod+Comma" = {
                    action.spawn = noctaliaCall "settings toggle";
                    hotkey-overlay.title = "Noctalia: Open/Close settings";
                  };
                  "Mod+Ctrl+L" = {
                    action.spawn = noctaliaCall "lockScreen lock";
                    hotkey-overlay.title = "Noctalia: Lock screen";
                  };
                  "Mod+Shift+E" = {
                    action.spawn = noctaliaCall "sessionMenu toggle";
                    hotkey-overlay.title = "Noctalia: Open/Close session menu";
                  };
                });
            };
          };
          fuzzel = lib.mkIf (cfg.defaultApps.appLauncher.name == "fuzzel") {
            enable = mkDefault true;
            settings = {
              main = {
                terminal = mkDefault (lib.getExe cfg.defaultApps.terminal.package);
              };
            };
          };
        };
        home.packages = [ pkgs.kdePackages.ark ];
      }
      (lib.mkIf cfg.noctalia.enable {
        wunkus.presets.programs.niri.defaultApps = {
          appLauncher = {
            name = "";
            package = null;
          };
          screenShotter = {
            name = "";
            package = null;
          };
        };
        programs.noctalia-shell = {
          enable = mkDefault true;
          settings = {
            appLauncher.terminalCommand = "${lib.getExe cfg.defaultApps.terminal.package} -e";
            location = {
              name = "Cincinnati";
              useFahrenheit = true;
            };
            general.avatarImage = ../themes/data/stylish/burger_king_cropped.png;
          };
          systemd.enable = mkDefault true;
        };
      })
    ]
  );
}
