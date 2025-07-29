{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.wunkus.hardware."kvm-x86_64-linux";
  inherit (lib) mkDefault mkEnableOption mkIf;
in
{
  options = {
    wunkus.hardware."kvm-x86_64-linux".enable = mkEnableOption "kvm x86_64-linux hardware config";
  };
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
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
