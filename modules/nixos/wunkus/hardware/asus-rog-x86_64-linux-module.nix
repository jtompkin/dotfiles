{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.wunkus.hardware."asusRog-x86_64-linux";
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    wunkus.hardware."asusRog-x86_64-linux".enable =
      mkEnableOption "asus ROG x86_64-linux hardware config";
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
