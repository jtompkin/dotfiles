{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    ;
  cfg = config.wunkus.presets.programs.walker;
in
{
  options = {
    wunkus.presets.programs.walker = {
      enable = mkEnableOption "walker application launcher preset config";
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile."elephant/websearch.toml".source =
      (pkgs.formats.toml { }).generate "websearch.toml"
        {
          entries = [
            {
              default = true;
              name = "DuckDuckGo";
              prefix = "ddg ";
              url = "https://duckduckgo.com/?q=%TERM%";
            }
            {
              name = "Google";
              prefix = "goo ";
              url = "https://www.google.com/search?q=%TERM%";
            }
          ];
        };
    programs.walker = {
      enable = mkDefault true;
      runAsService = mkDefault true;
      config = {
        keybinds = {
          next = "ctrl j";
          previous = "ctrl k";
          quick_activate = [
            "ctrl a"
            "ctrl s"
            "ctrl d"
            "ctrl f"
          ];
        };
      };
    };
  };
}
