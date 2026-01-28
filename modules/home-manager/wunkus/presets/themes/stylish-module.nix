{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.themes.stylish;
in
{
  options.wunkus.presets.themes.stylish = {
    enable = lib.mkEnableOption "theming using stylix";
  };
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = mkDefault true;
      base16Scheme = mkDefault "${pkgs.vimPlugins.nightfox-nvim}/extra/carbonfox/base16.yaml";
      fonts = {
        monospace = {
          name = mkDefault "Iosevka Nerd Font";
          package = mkDefault pkgs.nerd-fonts.iosevka;
        };
        sizes.terminal = mkDefault 16;
      };
      cursor = {
        name = mkDefault "Bibata-Modern-Classic";
        package = mkDefault pkgs.bibata-cursors;
        size = mkDefault 24;
      };
      targets.neovim.enable = !config.wunkus.presets.programs.neovim.enable;
    };
  };
}
