{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.shellExtras;
  inherit (lib) mkDefault;
in
{
  options.wunkus.presets.programs.shellExtras.enable =
    lib.mkEnableOption "nh, direnv, zoxide, bat, fzf, fd, ripgrep configuration";
  config = lib.mkIf cfg.enable {
    programs = {
      nh = {
        enable = mkDefault true;
        homeFlake = mkDefault config.wunkus.settings.flakeDir;
        osFlake = mkDefault config.wunkus.settings.flakeDir;
      };
      zoxide.enable = mkDefault true;
      bat = {
        enable = mkDefault true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
          batpipe
        ];
      };
      zsh = lib.mkIf config.programs.zsh.enable {
        initContent = lib.mkIf config.programs.bat.enable ''
          eval "$(batpipe)"
        '';
      };
      direnv = {
        enable = mkDefault true;
        nix-direnv.enable = mkDefault true;
      };
      fzf = {
        enable = mkDefault true;
      };
      eza = {
        enable = true;
        extraOptions =
          lib.mkIf
            (!(config.wunkus.presets.programs.zim.enable || config.wunkus.presets.programs.zshDiy.enable))
            [
              "--group-directories-first"
              "--header"
              "--smart-group"
              "--git"
            ];
      };
      fastfetch.enable = mkDefault true;
      htop.enable = mkDefault true;
      btop.enable = mkDefault true;
      fd.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
    };
  };
}
