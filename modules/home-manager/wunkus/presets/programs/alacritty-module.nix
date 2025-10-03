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
    home.packages = [
      pkgs.nerd-fonts.meslo-lg
      pkgs.nerd-fonts.iosevka
    ];
    programs = {
      alacritty = {
        enable = mkDefault true;
        theme = mkDefault "carbonfox";
        package = lib.mkIf config.wunkus.profiles.gui.nixgl.enable (config.lib.nixGL.wrap pkgs.alacritty);
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
    xdg.configFile."kitty/kitty.conf" = {
      enable = !config.wunkus.presets.programs.kitty.enable;
      text = ''
        font_family MesloLGS Nerd Font
        font_size 18.0
        foreground #f2f4f8
        background #161616
      '';
    };
  };
}
