{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.kitty;
in
{
  options.wunkus.presets.programs.kitty.enable = lib.mkEnableOption "kitty terminal preset config";
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (!config.wunkus.presets.themes.stylish.enable) {
        wunkus.presets.themes.dark.font = config.programs.kitty.font;
        fonts.fontconfig.enable = mkDefault true;
        programs.kitty = {
          font = {
            name = mkDefault "Iosevka Nerd Font";
            package = mkDefault pkgs.nerd-fonts.iosevka;
            size = mkDefault 16;
          };
          themeFile = "Carbonfox";
        };
      })
      {
        programs.kitty = {
          enable = mkDefault true;
          settings = {
            enable_audio_bell = "no";
          };
        };
      }
    ]
  );
}
