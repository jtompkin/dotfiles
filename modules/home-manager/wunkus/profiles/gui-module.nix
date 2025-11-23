{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.gui;
  inherit (lib) mkDefault;
in
{
  options.wunkus.profiles.gui = {
    enable = lib.mkEnableOption "gui home-manager on non-NixOS systems profile";
  };
  config = lib.mkIf cfg.enable {
    targets.genericLinux = {
      enable = mkDefault true;
      gpu.enable = mkDefault true;
    };
    home.packages = with pkgs; [
      xclip
    ];
    wunkus.presets.programs.kitty.enable = true;
    programs.mpv.enable = mkDefault true;
    fonts.fontconfig.enable = mkDefault true;
  };
}
