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
    backgrounds = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      default = {
        mountain-peak-nighttime = pkgs.fetchurl {
          name = "mountain_peak_nighttime.jpg";
          url = "https://unsplash.com/photos/a0TJ3hy-UD8/download?force=true";
          hash = "sha256-IxglIxt/7FM21GE5ntX0j+CdjRKAW7S3uAkARS46q10=";
        };
        space-shuttle-launch = pkgs.fetchurl {
          name = "space_shuttle_columbia_launch.jpg";
          url = "https://www.flickr.com/photo_download.gne?id=18307879358&secret=551f450ed5&size=o&source=photoPageEngagement";
          hash = "sha256-R8k/6kG+aXxmGTdBUz+i88F1Hczk1XaqnMGlcgCGpM0=";
        };
        hubble-eye-nebula = pkgs.fetchurl {
          name = "hubbele_eye_nebula.jpg";
          url = "https://www.flickr.com/photo_download.gne?id=9467318602&secret=4ec6ae7bb4&size=o&source=photoPageEngagement";
          hash = "sha256-28vjt4KEAZDR3f8YsoJikNRBuDwmZAAoutBP7gxX88s=";
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = mkDefault true;
      base16Scheme = mkDefault "${pkgs.vimPlugins.nightfox-nvim}/extra/carbonfox/base16.yaml";
      image = mkDefault cfg.backgrounds.mountain-peak-nighttime;
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
