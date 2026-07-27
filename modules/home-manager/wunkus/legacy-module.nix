{ lib, config, ... }:
let
  cfg = config.wunkus.legacy;
  svIsEnabled = sv: cfg.${sv}.enable;
in
{
  options.wunkus.legacy = {
    enable = lib.mkEnableOption "configuration required to suppress legacy config warnings";
    "26.05".enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "stateVersion 26.05";
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (svIsEnabled "26.05") {
        programs.neovim = {
          withRuby = false;
          withPython3 = false;
        };
      })
    ]
  );
}
