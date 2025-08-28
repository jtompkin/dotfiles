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
  cfg = config.wunkus.presets.programs.hyprland;
in
{
  options = {
    wunkus.presets.programs.hyprland = {
      enable = mkEnableOption "Hyprland preset config";
      minimal = mkEnableOption "Hyprland minimal config";
      terminal = mkOption {
        type = types.str;
        default = "alacritty";
      };
      fileManager = mkOption {
        type = types.str;
        default = "thunar";
      };
      menu = mkOption {
        type = types.str;
        default = "bemenu-run";
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
    };
  };
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = mkDefault true;
      systemd.enable = true;
      package = mkDefault null;
      settings = {
        "$mainMod" = "SUPER";
        monitor = [
          "eDP-1, preferred, 0x0, 1.2"
          "desc:HP Inc. HP E24q G5 CNC3351FZT, preferred, auto, 1.6"
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
          # sensitivity = -0.85;
          touchpad.natural_scroll = false;
        };
        gestures.workspace_swipe = false;
        bind = [
          "$mainMod, RETURN, exec, uwsm app -- ${cfg.terminal}"
          "$mainMod, Q, killactive"
          # "$mainMod, X, exec, $pymenu control"
          "$mainMod, X, exec, uwsm stop"
          "$mainMod SHIFT, M, exec, $pymenu monitor"
          "$mainMod, E, exec, uwsm app -- ${cfg.fileManager}"
          "$mainMod, SPACE, togglefloating"
          "$mainMod, D, exec, ${cfg.menu}"
          "$mainMod, P, pseudo"
          "$mainMod, O, togglesplit"
          "$mainMod, F, fullscreen"
          "$mainMod, V, exec, cliphist list | bemenu | cliphist decode | wl-copy"
          "$mainMod SHIFT, P, exec, $pymenu power-profile --switch"
          "$mainMod SHIFT CONTROL, P, exec, $pymenu power-profile"

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
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_SINK@ 2%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 2%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", xf86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set +33%"
          ", xf86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 33%-"
        ];
        bindl = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
        ];
        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "float, title:Bluetooth Devices"
          "float, class:nm-connection-editor"
        ];
      };
    };
    programs = {
      waybar = {
        systemd.enable = mkDefault true;
        systemd.target = mkDefault "hyprland-session.target";
      };
    };
    services = mkIf (!cfg.minimal) {
      network-manager-applet.enable = mkDefault true;
      mako.enable = mkDefault true;
      blueman-applet.enable = mkDefault true;
      hyprpaper.enable = mkDefault true;
      hyprpaper.settings = mkIf (cfg.defaultWallpaper != null) {
        preload = [ cfg.defaultWallpaper ];
        wallpaper = [ ", ${cfg.defaultWallpaper}" ];
      };
    };
    wunkus.presets.programs = {
      bemenu.enable = mkDefault true;
      alacritty.enable = mkDefault true;
      waybar.enable = mkDefault true;
    };
    home.packages = [
      pkgs.xfce.thunar
      pkgs.walker
      pkgs.networkmanagerapplet
    ];
    xdg.portal.enable = true;
    xdg.portal.config.hyprland.default = [ "hyprland" ];
  };
}
