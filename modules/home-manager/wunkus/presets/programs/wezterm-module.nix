{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.wezterm;
in
{
  options.wunkus.presets.programs.wezterm.enable = lib.mkEnableOption "wezterm preset config";
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.nerd-fonts.meslo-lg
    ];
    programs = {
      alacritty = {
        enable = mkDefault true;
        theme = mkDefault "carbonfox";
        settings = {
          terminal.shell = lib.mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
          font.normal = {
            family = "MesloLGS Nerd Font";
            style = "Regular";
          };
        };
      };
    };
    fonts.fontconfig.enable = mkDefault true;
    xdg.configFile."kitty/kitty.conf".text = ''
      font_family MesloLGS Nerd Font
      font_size 14.0
      foreground #f2f4f8
      background #161616
    '';
  };
}
