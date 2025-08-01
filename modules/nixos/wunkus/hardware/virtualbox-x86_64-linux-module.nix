{
  lib,
  config,
  ...
}:
let
  cfg = config.wunkus.hardware."virtualbox-x86_64-linux";
  inherit (lib) mkDefault mkEnableOption mkIf;
in
{
  options = {
    wunkus.hardware."virtualbox-x86_64-linux".enable =
      mkEnableOption "virtualbox x86_64-linux hardware config";
  };
  config = mkIf cfg.enable {
    boot = {
      initrd = {
        availableKernelModules = [
          "ata_piix"
          "ohci_pci"
          "ehci_pci"
          "ahci"
          "sd_mod"
          "sr_mod"
        ];
        kernelModules = [ "dm-snapshot" ];
      };
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

    networking.useDHCP = mkDefault true;

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";
    virtualisation.virtualbox.guest.enable = true;
  };
}
