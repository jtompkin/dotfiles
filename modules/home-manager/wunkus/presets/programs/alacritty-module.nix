{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.alacritty;
in
{
  options.wunkus.presets.programs.alacritty.enable = lib.mkEnableOption "alacritty preset config";
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.iosevka ];
    programs = {
      alacritty = {
        enable = mkDefault true;
        theme = mkDefault "carbonfox";
        settings = {
          terminal.shell = lib.mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
          font = {
            size = 20;
            normal = {
              family = "Iosevka Nerd Font Mono";
              style = "Regular";
            };
          };
        };
      };
    };
    fonts.fontconfig.enable = mkDefault true;
  };
}
