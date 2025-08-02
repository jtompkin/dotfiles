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

    fileSystems."/" = {
      device = "/dev/mapper/nixvg-nixos";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    fileSystems."/home" = {
      device = "/dev/mapper/nixvg-nixos";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    fileSystems."/home/.snapshots" = {
      device = "/dev/mapper/nixvg-nixos";
      fsType = "btrfs";
      options = [ "subvol=@home@.snapshots" ];
    };

    fileSystems."/nix" = {
      device = "/dev/mapper/nixvg-nixos";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

    fileSystems."/persist" = {
      device = "/dev/mapper/nixvg-nixos";
      fsType = "btrfs";
      options = [ "subvol=@persist" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/76FA-8443";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/mapper/nixvg-swap"; }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
