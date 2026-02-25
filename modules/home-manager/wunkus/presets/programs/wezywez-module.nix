{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.wezywez;
  cfgStylish = config.wunkus.presets.themes.stylish;
  keybindType =
    { config, ... }:
    {
      options = {
        key = lib.mkOption {
          type = lib.types.str;
          description = "Key to activate binding";
        };
        mods = lib.mkOption {
          type = lib.types.listOf (
            lib.types.enum [
              "SUPER"
              "CTRL"
              "SHIFT"
              "ALT"
              "LEADER"
              "VoidSymbol"
            ]
          );
          default = [ ];
          description = "List of modifier labels that must be pressed along with the key";
        };
        action = lib.mkOption {
          type = lib.types.lines;
          description = "Lua code to run when the keybind is pressed";
        };
        rawAction = lib.mkOption {
          type = lib.types.bool;
          default = lib.hasPrefix "wezterm.action." config.action || config.action == "";
          description = "If true, do not do any processing on the action string of this keybind";
        };
        finalBind = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          readOnly = true;
          internal = true;
          default = {
            inherit (config) key;
            mods = lib.mkIf (config.mods != [ ]) (
              builtins.concatStringsSep "|" (lib.uniqueStrings config.mods)
            );
            action = lib.mkLuaInline (
              if config.rawAction then
                config.action
              else
                builtins.replaceStrings [ "_A." ] [ "wezterm.action." ] ("wezterm.action." + config.action)
            );
          };
        };
      };
    };
in
{
  options.wunkus.presets.programs.wezywez = {
    enable = lib.mkEnableOption "Wezterm configuration";
    enableDefaultBinds = lib.mkEnableOption "default key bindings defined by Wezterm";
    enableTmuxBinds = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable tmux-like bindings";
    };
    keybinds = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule keybindType);
      default = [ ];
    };
    keyTables = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf (lib.types.submodule keybindType));
      default = { };
    };
    colorScheme = lib.mkOption {
      type = lib.types.str;
      default = "carbonfox";
      description = "The color scheme to be used.\nSee: https://wezterm.org/colorschemes/index.html";
    };
    enableAudibleBell = lib.mkEnableOption "the audible bell on startup";
    enableTabBar = lib.mkEnableOption "the tab bar on startup";
    font = lib.mkOption {
      type = lib.hm.types.fontType;
      default = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font";
        size = 16;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!cfgStylish.enable) [ cfg.font.package ];
    wunkus.presets.programs.wezywez = lib.mkMerge [
      {
        keybinds = [
          {
            key = "P";
            mods = [
              "CTRL"
              "SHIFT"
            ];
            action = "ActivateCommandPalette";
          }
          {
            key = "L";
            mods = [
              "CTRL"
              "SHIFT"
            ];
            action = "ShowDebugOverlay";
          }
          {
            key = "F";
            mods = [
              "CTRL"
              "SHIFT"
            ];
            action = "ToggleFullScreen";
          }
        ];
      }
      (lib.mkIf cfg.enableTmuxBinds {
        keybinds = lib.singleton {
          key = "B";
          mods = [
            "CTRL"
            "SHIFT"
          ];
          action = "ActivateKeyTable{name = 'tmux'}";
        };
        keyTables = import ./wezywez/tmux-tables.nix lib;
      })
    ];
    programs.wezterm = {
      enable = mkDefault true;
      extraConfig = lib.mkMerge [
        (lib.mkIf (!cfgStylish.enable) (
          lib.mkMerge [
            (lib.mkBefore ''
              local config = wezterm.config_builder()
              config.color_scheme = "${cfg.colorScheme}"
              config.font = wezterm.font_with_fallback{ "${cfg.font.name}", "Noto Color Emoji" }
              config.window_frame = { font = wezterm.font{ family = "${cfg.font.name}", weight = "Bold" } }
              config.font_size = ${toString cfg.font.size}
            '')
            (lib.mkAfter "return config\n")
          ]
        ))
        ''
          config.audible_bell = "${if cfg.enableAudibleBell then "SystemBeep" else "Disabled"}"
          config.command_palette_font_size = config.font_size
          config.enable_tab_bar = ${if cfg.enableTabBar then "true" else "false"}
          config.disable_default_key_bindings = ${if cfg.enableDefaultBinds then "false" else "true"}
          config.keys = ${lib.generators.toLua { } (map (bind: bind.finalBind) cfg.keybinds)}
          config.key_tables = ${
            lib.generators.toLua { } (
              builtins.mapAttrs (table: binds: map (bind: bind.finalBind) binds) cfg.keyTables
            )
          }
          ${lib.concatMapStrings (
            f: "-- START: ${baseNameOf f}\n" + lib.readFile f + "-- END: ${baseNameOf f}\n"
          ) (config.lib.dotfiles.listLuaFiles ./data/wezywez)}
        ''
      ];
    };
  };
}
