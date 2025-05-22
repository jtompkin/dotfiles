{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.shellExtras;
  inherit (lib) mkIf;
in
{
  options.wunkus.presets.programs.shellExtras.enable =
    lib.mkEnableOption "oh-my-posh, zoxide, bat, fzf, fd, ripgrep configuration";
  config = mkIf cfg.enable {
    programs = {
      oh-my-posh = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ./shellExtras/themes/my_space.omp.toml);
      };
      zoxide = {
        enable = true;
        options = [
          "--cmd"
          "cd"
        ];
      };
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batgrep
          batwatch
          batpipe
        ];
      };
      fzf = {
        enable = true;
        changeDirWidgetCommand = "";
      };
      fd.enable = true;
      ripgrep.enable = true;
    };

  };
}
