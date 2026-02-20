{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.wezywez;
  keybindType = (
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
            mods = builtins.concatStringsSep "|" config.mods;
            action = lib.mkLuaInline (
              if config.rawAction then config.action else "wezterm.action." + config.action
            );
          };
        };
      };
    }
  );
in
{
  options.wunkus.presets.programs.wezywez = {
    enable = lib.mkEnableOption "Wezterm configuration";
    enableDefaultBinds = lib.mkEnableOption "default key bindings defined by Wezterm";
    keybinds = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule keybindType);
      default = [ ];
    };
    keyTables = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf (lib.types.submodule keybindType));
      default = { };
    };
    font = lib.mkOption {
      type = lib.hm.types.fontType;
      default = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font";
        size = 20;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (!config.wunkus.presets.themes.stylish.enable) [ cfg.font.package ];
    wunkus.presets.programs.wezywez.keybinds = [
      {
        key = "p";
        mods = [
          "CTRL"
          "SHIFT"
        ];
        action = "ActivateCommandPalette";
      }
      {
        key = "Enter";
        mods = [
          "ALT"
          "SHIFT"
        ];
        action = "ToggleFullScreen";
      }
      {
        key = "B";
        mods = [
          "CTRL"
          "SHIFT"
        ];
        action = # lua
          ''ActivateKeyTable({ name = "tmux" })'';
      }
    ];
    wunkus.presets.programs.wezywez.keyTables = {
      tmux = [
        {
          key = "c";
          action = ''SpawnTab("CurrentPaneDomain")'';
        }
      ];
    };
    programs.wezterm = {
      enable = mkDefault true;
      extraConfig =
        lib.optionalString (!config.wunkus.presets.themes.stylish.enable) ''
          local wezterm = require("wezterm")
          local config = wezterm.config_builder()
          config.color_scheme = "carbonfox"
          config.font = wezterm.font_with_fallback({ "${cfg.font.name}", "Noto Color Emoji" })
          config.window_frame =
          	{ font = wezterm.font({ family = "${cfg.font.name}", weight = "Bold" }) }
          config.font_size = ${toString cfg.font.size}
        ''
        + ''
          config.audible_bell = "Disabled"
          config.command_palette_font_size = config.font_size
          config.enable_tab_bar = false
          config.disable_default_key_bindings = ${if cfg.enableDefaultBinds then "false" else "true"}
          config.keys = ${lib.generators.toLua { } (map (bind: bind.finalBind) cfg.keybinds)}
          config.key_tables = ${
            lib.generators.toLua { } (
              builtins.mapAttrs (table: binds: map (bind: bind.finalBind) binds) cfg.keyTables
            )
          }
        ''
        + lib.concatMapStrings (
          f: "-- START: ${baseNameOf f}\n" + lib.readFile f + "-- END: ${baseNameOf f}\n"
        ) (config.lib.dotfiles.listLuaFiles ./data/wezywez)
        + lib.optionalString (!config.wunkus.presets.themes.stylish.enable) "return config\n";
    };
  };
}
