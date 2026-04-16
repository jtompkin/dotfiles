{ lib, config, ... }:
let
  cfg = config.wunkus.legacy;
in
{
  options.wunkus.legacy = {
    enable = lib.mkEnableOption "configuration required to suppress legacy config warnings";
    enable2605 = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.enable2605 {
        programs.neovim = {
          withRuby = false;
          withPython3 = false;
        };
        gtk.gtk4.theme = null;
      })
    ]
  );
}
