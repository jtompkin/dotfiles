{
  pkgs,
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
    environment.systemPackages = [
      pkgs.nvitop
    ];
    boot.extraModprobeConfig = ''
      # options nvidia NVreg_PreserveVideoMemoryAllocations=1
      options nvidia NVreg_UsePageAttributeTable=1
    '';
    hardware.graphics.enable = mkDefault true;
    services.xserver.videoDrivers = [
      "nvidia"
      "modesetting"
    ];
    hardware.nvidia = {
      open = mkDefault false;
      powerManagement.enable = mkDefault true;
      powerManagement.finegrained = mkDefault true;
      prime = {
        intelBusId = mkDefault cfg.intelBusId;
        nvidiaBusId = mkDefault cfg.nvidiaBusId;
        offload.enable = true;
        offload.enableOffloadCmd = mkDefault true;
      };
    };
  };
}
