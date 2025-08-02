{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.presets.programs.bemenu;
in
{
  options = {
    wunkus.presets.programs.bemenu.enable = mkEnableOption "bemenu preset config";
  };
  config = mkIf cfg.enable {
    programs.bemenu = {
      enable = mkDefault true;
      settings = {
        ignorecase = true;
        no-cursor = true;
        wrap = true;
        single-instance = true;
        fixed-height = true;
        binding = "vim";
        vim-esc-exits = true;
        center = true;
        list = "30 down";
        border = 5;
        border-radius = 5;
        width-factor = 0.8;
        fn = "Meslo LGS Nerd Font 12";
        prompt = "watcha want?";
        bdr = "#6c71c4";
        hf = "#6c71c4";
        tf = "#eb3834";
      };
    };
  };
}
