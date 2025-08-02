{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    ;
  cfg = config.wunkus.profiles.nvidia;
in
{
  options = {
    wunkus.profiles.nvidia = {
      enable = mkEnableOption "nvidia profiles configuration";
      intelBusId = mkOption {
        type = lib.types.str;
        default = "PCI:0:2:0";
      };
      nvidiaBusId = mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
      };
    };
  };
  config = mkIf cfg.enable {
    hardware.graphics.enable = mkDefault true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = mkDefault false;
      prime = {
        intelBusId = mkDefault cfg.intelBusId;
        nvidiaBusId = mkDefault cfg.nvidiaBusId;
        offload.enable = mkDefault true;
        offload.enableOffloadCmd = mkDefault true;
      };
    };
  };
}
