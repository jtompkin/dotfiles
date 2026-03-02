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
        name = "mountain_peak_nighttime.jpg";
        url = "https://unsplash.com/photos/a0TJ3hy-UD8/download?force=true&w=2400";
        hash = "sha256-F3/wWrIGnSPARNaQ0nB6y+TgvTlW+Dh6KH1ak5BuBe8=";
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
