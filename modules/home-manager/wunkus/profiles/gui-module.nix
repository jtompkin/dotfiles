{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.gui;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.gui.enable = lib.mkEnableOption "gui home-manager profile";
  options.wunkus.profiles.gui.nixgl.enable =
    lib.mkEnableOption "gui home-manager profile with nixGL support";
  config = mkIf cfg.enable {
    warnings =
      if cfg.nixgl.enable && !cfg.enable then
        [
          ''
            You have enable nixGL support but not the gui module. No configuration 
            will be changed without enabling the gui module.
          ''
        ]
      else
        [ ];
    home.packages = with pkgs; [
      xsel
      xclip
      nerd-fonts.meslo-lg
    ];
    programs = {
      alacritty = {
        enable = mkDefault true;
        package = mkIf cfg.nixgl.enable (config.lib.nixGL.wrap pkgs.alacritty);
        theme = mkDefault "carbonfox";
        settings = {
          terminal.shell = mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
          font.normal = {
            family = "MesloLGS Nerd Font";
            style = "Regular";
          };
        };
      };
      mpv = {
        enable = mkDefault true;
        package = mkIf cfg.nixgl.enable (config.lib.nixGL.wrap pkgs.alacritty);
      };
    };
    fonts.fontconfig.enable = mkDefault true;
    nixGL = {
      installScripts = [ "mesa" ];
      packages = pkgs.nixgl;
    };
  };
}
