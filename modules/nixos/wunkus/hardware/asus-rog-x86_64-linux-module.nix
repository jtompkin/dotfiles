{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.hardware."asusRog-x86_64-linux";
  inherit (lib) mkDefault mkEnableOption mkIf;
in
{
  options = {
    wunkus.hardware."asusRog-x86_64-linux".enable =
      mkEnableOption "asus ROG x86_64-linux hardware config";
  };

  config = mkIf cfg.enable {
    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "xhci_pci"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
        ];
        kernelModules = [ "dm-snapshot" ];
      };
      kernelModules = [ "kvm-amd" ];
      extraModulePackages = [ ];
    };

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  };
}
