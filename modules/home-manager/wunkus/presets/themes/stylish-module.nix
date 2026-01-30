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
      image = pkgs.fetchurl {
        url = "https://upload.wikimedia.org/wikipedia/commons/5/5d/PIA21590_%E2%80%93_Blue_Rays%2C_New_Horizons%27_High-Res_Farewell_to_Pluto.jpg";
        hash = "sha256-kUsqhjIOElXPoshxlDeYOxlXKGajH37U1SfpGAdsIzk=";
      };
      fonts = {
        monospace = {
          name = mkDefault "Iosevka Nerd Font";
          package = mkDefault pkgs.nerd-fonts.iosevka;
        };
        sizes.terminal = mkDefault 16;
      };
      icons = {
        enable = mkDefault true;
        dark = mkDefault "breeze-dark";
        light = mkDefault "breeze-light";
        package = mkDefault pkgs.kdePackages.breeze-icons;
      };
      cursor = {
        name = mkDefault "Bibata-Modern-Classic";
        package = mkDefault pkgs.bibata-cursors;
        size = mkDefault 24;
      };
      polarity = "dark";
      targets = lib.genAttrs [ "neovide" "neovim" "nixvim" "nvf" "vim" ] (target: {
        enable = !config.wunkus.presets.programs.neovim.enable;
      });
    };
  };
}
