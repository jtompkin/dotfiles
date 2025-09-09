{ config, lib, ... }:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.wunkus.presets.programs.anyrun;
in
{
  options = {
    wunkus.presets.programs.anyrun = {
      enable = mkEnableOption "anyrun preset config";
      plugins = mkOption {
        type = types.listOf types.str;
        default = [
          "libapplications.so"
          "libsymbols.so"
          "librink.so"
          "libshell.so"
          "librandr.so"
          "libnix_run.so"
          "libwebsearch.so"
        ];
      };
    };
  };
  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = mkDefault true;
      config = {
        plugins = map (plugin: "${config.programs.anyrun.package}/lib/${plugin}") cfg.plugins;
        x.fraction = mkDefault 0.5;
        y.fraction = mkDefault 0.5;
        width.fraction = 0.5;
        height.fraction = mkDefault 0.5;
        ignoreExclusiveZones = mkDefault true;
        showResultsImmediately = mkDefault true;
      };
      extraConfigFiles = {
        "symbols.ron" = mkIf (lib.elem "libsymbols.so" cfg.plugins) {
          text = ''
            Config(
              prefix: ":sym ",
            )
          '';
        };
        "websearch.ron" = mkIf (lib.elem "libwebsearch.so" cfg.plugins) {
          text = ''
            Config(
              engines: [DuckDuckGo],
            )
          '';
        };
      };
    };
  };
}
