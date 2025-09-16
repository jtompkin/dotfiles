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
  cfg = config.wunkus.presets.programs.hyprland;
  uwsmExe = lib.getExe pkgs.uwsm;
  withUwsm =
    {
      app,
      exe ? app.name,
      extra ? "",
      offload ? false,
    }:
    "${uwsmExe} app -- ${lib.optionalString offload "nvidia-offload "}${lib.getExe' app.package exe} ${extra}";
  defaultAppType =
    { config, name, ... }:
    let
      appTypeAppsMap = {
        terminal = [
          "alacritty"
          "foot"
        ];
        fileManager = [ "thunar" ];
        appLauncher = [
          "walker"
          "anyrun"
        ];
        screenShotter = [
          "hyprshot"
          "flameshot"
        ];
        imageViewer = [ "feh" ];
      };
    in
    {
      options = {
        name = mkOption {
          type = types.enum appTypeAppsMap.${config.appType};
          default = lib.head appTypeAppsMap.${config.appType};
          description = "Name of the program to be used as the default application for this application type";
        };
        appType = mkOption {
          type = types.enum (lib.attrNames appTypeAppsMap);
          default = name;
          readOnly = true;
          description = "Class of the program, based on the name";
        };
        package = mkOption {
          type = types.package;
          description = "Package to run in Hyprland";
        };
      };
    };
  isDefaultApp = type: name: cfg.defaultApps.${type}.name == name;
  getDefaltAppExe = type: lib.getExe cfg.defaultApps.${type}.package;
in
{
  options = {
    wunkus.presets.programs.hyprland = {
      enable = mkEnableOption "Hyprland preset config";
      minimal = mkEnableOption "Hyprland minimal config";
      nvidia = mkEnableOption "Nvidia specific settings";
      asus = mkEnableOption "Asus specific settings";
      defaultApps = mkOption {
        type = types.attrsOf (types.submodule defaultAppType);
        default = { };
      };
      defaultWallpaper = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to png image file to use as default wallpaper";
      };
      wallpaperDir = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      lockBackground = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to image to use as lock screen background";
      };
      lockoutTime = mkOption {
        type = lib.types.int;
        default = 300;
        description = "Number of idle seconds before screen is locked. Set to 0 to disable automatic locking";
      };
      suspendTime = mkOption {
        type = lib.types.int;
        default = 900;
        description = "Number of idle seconds before the system is suspended. Set to 0 to disable automatic suspension";
      };
    };
  };
  config = mkIf cfg.enable {
    wunkus.presets.programs.hyprland.defaultApps = {
      terminal.package =
        {
          alacritty = config.programs.alacritty.package;
          foot = config.programs.foot.package;
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
    };
    wayland.windowManager.hyprland = {
      enable = mkDefault true;
      systemd.enable = true;
      package = mkDefault null;
      settings = {
        "$mainMod" = "SUPER";
        monitor = [
          "eDP-1, preferred, 0x0, 1"
          "desc:HP Inc. HP E24q G5 CNC3351FZT, 2560x1440@74.97, auto, 1"
          ", preferred, auto, 1"
        ];
        general = {
          gaps_in = 3;
          gaps_out = 3;
          border_size = 2;
          "col.active_border" = "rgb(6C71C4) rgb(9B31E0) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = true;
          layout = "dwindle";
        };
        decoration = {
          rounding = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
          blur = {
            enabled = false;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        master.new_status = "master";
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };
        input = {
          kb_layout = "us";
          kb_options = "caps:swapescape";
          numlock_by_default = true;
          follow_mouse = 1;
          touchpad.natural_scroll = false;
        };
        gestures.workspace_swipe = false;
        env = mkMerge [
          (mkIf (isDefaultApp "screenShotter" "hyprshot") [
            "HYPRSHOT_DIR, ${config.programs.hyprshot.saveLocation}"
          ])
        ];
        bind = mkMerge [
          [
            "$mainMod, RETURN, exec, ${withUwsm { app = cfg.defaultApps.terminal; }}"
            "$mainMod, E, exec, ${withUwsm { app = cfg.defaultApps.fileManager; }}"
            "$mainMod, I, exec, ${
              withUwsm {
                app = {
                  package = config.programs.firefox.finalPackage;
                  name = "firefox";
                };
                offload = cfg.nvidia;
              }
            }"
            "$mainMod, D, exec, ${getDefaltAppExe "appLauncher"}"
            "$mainMod, X, exec, ${uwsmExe} stop"
            (
              ", Print, exec, ${getDefaltAppExe "screenShotter"} "
              + (lib.optionalString (isDefaultApp "screenShotter" "flameshot") "gui")
              + (lib.optionalString (isDefaultApp "screenShotter" "hyprshot") "-m window")
            )
            "$mainMod, Print, exec, ${lib.getExe pkgs.hyprpicker} -a"

            "$mainMod CTRL, L, Exec, hyprlock"
            "$mainMod, Q, killactive"
            "$mainMod, SPACE, togglefloating"
            "$mainMod, P, pseudo"
            "$mainMod, O, togglesplit"
            "$mainMod, F, fullscreen"

            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"
            "$mainMod, H, movefocus, l"
            "$mainMod, L, movefocus, r"
            "$mainMod, K, movefocus, u"
            "$mainMod, J, movefocus, d"

            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            "$mainMod, M, togglespecialworkspace, magic"
            "$mainMod, M, movetoworkspace, +0"
            "$mainMod, M, togglespecialworkspace, magic"
            "$mainMod, M, movetoworkspace, special:magic"
            "$mainMod, M, togglespecialworkspace, magic"

            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
            "$mainMod, mouse:274, killactive"
          ]
          (mkIf (isDefaultApp "screenShotter" "hyprshot") [
            "SHIFT, Print, exec, ${getDefaltAppExe "screenShotter"} -m region"
            "$mainMod CTRL, Print, exec, ${getDefaltAppExe "screenShotter"} --freeze"
          ])
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        bindel =
          let
            wpctlExe = lib.getExe' pkgs.wireplumber "wpctl";
          in
          [
            ", XF86AudioRaiseVolume, exec, ${wpctlExe} set-volume -l 1 @DEFAULT_SINK@ 2%+"
            ", XF86AudioLowerVolume, exec, ${wpctlExe} set-volume @DEFAULT_SINK@ 2%-"
            ", XF86AudioMute, exec, ${wpctlExe} set-mute @DEFAULT_SINK@ toggle"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
            ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
            ", xf86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set +33%"
            ", xf86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 33%-"
          ];
        bindl =
          let
            playerctlExe = lib.getExe config.services.playerctld.package;
          in
          [
            ", XF86AudioPlay, exec, ${playerctlExe} play-pause"
            ", XF86AudioPrev, exec, ${playerctlExe} previous"
            ", XF86AudioNext, exec, ${playerctlExe} next"
          ];
        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "float, title:Bluetooth Devices"
          "float, class:nm-connection-editor"
          "float, class:wev"
          "float, class:SystemInfo"
          "size 70% 70%, class:SystemInfo"
          "size 15% 70%, title:Proton VPN"
        ];
      };
    };

    programs = {
      feh = mkIf (isDefaultApp "imageViewer" "feh") { enable = true; };
      hyprshot = mkIf (isDefaultApp "screenShotter" "hyprshot") {
        enable = true;
        saveLocation = "${config.xdg.userDirs.pictures}/Screenshots";
      };
      waybar = {
        systemd = {
          enable = mkDefault true;
          target = mkDefault "hyprland-session.target";
        };
      };
      firefox.enable = mkDefault true;
      hyprlock = {
        enable = mkDefault true;
        settings = {
          background = mkIf (cfg.lockBackground != null) [
            {
              path = cfg.lockBackground;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "300, 50";
              outline_thickness = 3;
              dots_size = 0.33;
              dots_spacing = 0.15;
              dots_center = false;
              dots_rounding = -2;
              outer_color = "rgb(151515)";
              font_color = "rgb(200, 200, 200)";
              inner_color = "rgb(10, 10, 10)";
              fade_on_empty = true;
              fad_timeout = 1000;
              placeholder_text = "<i>Input password...</i>";
              hide_input = false;
              rounding = 7;
              check_color = "rgb(204, 136, 34)";
              fail_color = "rgb(204, 34, 34)";
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              fail_timeout = 2000;
              fail_transition = 300;
              capslock_color = -1;
              numlock_color = -1;
              bothlock_color = -1;
              invert_numlock = false;
              swap_font_color = false;
              position = "0, -20";
              halign = "center";
              valign = "center";
            }
          ];
          label = [
            {
              monitor = "";
              text = "$TIME";
              text_align = "center";
              color = "rgba(200, 200, 200, 1.0)";
              font_size = 50;
              rotate = 0;
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
          ];
          shape = [
            {
              monitor = "";
              size = "200, 100";
              color = "rgba(50, 50, 50, 0.75)";
              rounding = 7;
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };

    services = mkIf (!cfg.minimal) {
      network-manager-applet.enable = mkDefault true;
      dunst.enable = mkDefault true;
      blueman-applet.enable = mkDefault true;
      playerctld.enable = mkDefault true;
      flameshot = mkIf (isDefaultApp "screenShotter" "flameshot") {
        enable = true;
        settings = {
          General = {
            useGrimAdapter = true;
            disabledGrimWarning = true;
          };
        };
      };
      hyprsunset = {
        enable = mkDefault true;
        settings = {
          max-gamma = 150;
          profile = [
            {
              time = "7:30";
              identity = true;
            }
            {
              time = "21:00";
              temperature = 5500;
              gamma = 0.8;
            }
          ];
        };
      };
      hypridle = {
        enable = mkDefault true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener =
            lib.optional (cfg.lockoutTime > 0) {
              timeout = cfg.lockoutTime;
              on-timeout = "loginctl lock-session";
            }
            ++ lib.optional (cfg.suspendTime > 0) {
              timeout = cfg.suspendTime;
              on-timeout = "systemctl suspend";
            };
        };
      };
      hyprpaper = {
        enable = mkDefault true;
        settings = mkIf (cfg.defaultWallpaper != null) {
          preload = [ cfg.defaultWallpaper ];
          wallpaper = [ ", ${cfg.defaultWallpaper}" ];
        };
      };
    };
    wunkus.presets.programs = {
      anyrun = mkIf (isDefaultApp "appLauncher" "anyrun") { enable = true; };
      walker = mkIf (isDefaultApp "appLauncher" "walker") { enable = true; };
      alacritty = mkIf (isDefaultApp "terminal" "alacritty") { enable = true; };
      waybar.enable = mkDefault true;
    };
    home.packages = with pkgs; [
      networkmanagerapplet
      hyprpicker
      wl-clipboard
      wev
    ];
    xdg = {
      portal = {
        enable = true;
        config.hyprland.default = [ "hyprland" ];
      };
      userDirs.enable = true;
    };
  };
}
