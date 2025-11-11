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
  config = lib.mkIf cfg.enable {
    wunkus.presets.themes.dark.font = config.programs.kitty.font;
    fonts.fontconfig.enable = mkDefault true;
    programs.kitty = {
      enable = mkDefault true;
      font = {
        name = mkDefault "Iosevka Nerd Font";
        package = mkDefault pkgs.nerd-fonts.iosevka;
        size = mkDefault 16;
      };
      # TODO: Replace with `themeFile = "Carbonfox"` once pkgs.kitty-themes includes it
      extraConfig = lib.readFile "${
        pkgs.kitty-themes.overrideAttrs {
          version = "2025-10-23";
          src = pkgs.fetchFromGitHub {
            owner = "kovidgoyal";
            repo = "kitty-themes";
            rev = "6af4bcd7244a20ce4a0244c9128003473b97f319";
            hash = "sha256-oxNdwv5q3aEC6kCEZzZawrIYq0gYSVMjB4xVPb5WiEE=";
          };
        }
      }/share/kitty-themes/themes/Carbonfox.conf";
    };
  };
}
