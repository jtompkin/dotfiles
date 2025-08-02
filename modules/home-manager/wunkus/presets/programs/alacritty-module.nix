{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.wunkus.presets.programs.alacritty;
in
{
  options = {
    wunkus.presets.programs.alacritty.enable = mkEnableOption "alacritty preset config";
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.nerd-fonts.meslo-lg
    ];
    programs = {
      alacritty = {
        enable = mkDefault true;
        theme = mkDefault "carbonfox";
        settings = {
          terminal.shell = mkIf config.programs.zsh.enable (lib.getExe pkgs.zsh);
          font.normal = {
            family = "MesloLGS Nerd Font";
            style = "Regular";
          };
        };
      };
    };
    fonts.fontconfig.enable = mkDefault true;
    # nixGL = {
    #   installScripts = [ "mesa" ];
    #   packages = pkgs.nixgl;
    # };
  };
}
