{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.dualBooty;
  inherit (lib) mkIf mkDefault;
  getBtrfsSubvol = neededForBoot: name: {
    inherit neededForBoot;
    device = "/dev/nixvg/root";
    fsType = "btrfs";
    options = [
      "subvol=${name}"
      "compress=zstd"
      "noatime"
    ];
  };
in
{
  options.wunkus.profiles.dualBooty = {
    enable = lib.mkEnableOption "dual boot with windows profile";
    luksUUID = lib.mkOption {
      type = lib.types.str;
      description = "UUID of luks encrypted container";
    };
    espLabel = lib.mkOption {
      type = lib.types.str;
      default = "SYSTEM";
      description = "EFI system partition label";
    };
  };
  # Not using disko for this because I'm scared
  config = mkIf cfg.enable {
    time.hardwareClockInLocalTime = mkDefault true;
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          xbootldrMountPoint = "/boot";
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/efi";
        };
      };
      initrd.luks.devices."nixcrypt" = {
        device = "/dev/disk/by-uuid/${cfg.luksUUID}";
        allowDiscards = true;
      };
    };
    fileSystems = {
      "/" = getBtrfsSubvol false "@";
      "/home" = getBtrfsSubvol false "@home";
      "/home/.snapshots" = getBtrfsSubvol false "@home@.snapshots" // {
        depends = [ "/home" ];
      };
      "/nix" = getBtrfsSubvol true "@nix";
      "/persist" = getBtrfsSubvol true "@persist";
      "/efi" = {
        device = "/dev/disk/by-label/${cfg.espLabel}";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/XBOOT";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };
    swapDevices = [
      {
        device = "/dev/nixvg/swap";
        discardPolicy = "both";
      }
    ];
    zramSwap = {
      enable = mkDefault true;
      priority = mkDefault 100;
    };
  };
}
