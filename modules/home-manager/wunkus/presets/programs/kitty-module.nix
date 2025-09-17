{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.wunkus.presets.programs.kitty;
in
{
  options = {
    wunkus.presets.programs.kitty = {
      enable = mkEnableOption "kitty terminal preset config";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      kitty = {
        enable = mkDefault true;
        font = {
          name = mkDefault "Iosevka Nerd Font";
          package = mkDefault pkgs.nerd-fonts.iosevka;
          size = mkDefault 16;
        };
        # TODO: Does not exist in packaged kitty yet!
        # themeFile = "Carbonfox";
        extraConfig = lib.mkOrder 520 (builtins.readFile ./data/kitty/Carbonfox.conf);
      };
    };
    wunkus.presets.themes.dark.font = config.programs.kitty.font;
    fonts.fontconfig.enable = mkDefault true;
  };
}
