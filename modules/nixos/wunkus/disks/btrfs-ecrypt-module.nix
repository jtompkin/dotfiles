{ config, lib, ... }:
let
  cfg = config.wunkus.disks.btrfsEncrypt;
  inherit (lib) mkIf;
  mkSubvolume = name: {
    mountpoint = lib.replaceStrings [ "@" ] [ "/" ] name;
    mountOptions = [
      "compress=zstd"
      "noatime"
    ];
  };
in
{
  options = {
    wunkus.disks.btrfsEncrypt.enable = lib.mkEnableOption "encrypted btrfs disk config";
    wunkus.disks.btrfsEncrypt.swapSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "Size of ecrypted swap partition";
    };
    wunkus.disks.btrfsEncrypt.mainDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Device path for main disk";
    };
    wunkus.disks.btrfsEncrypt.extraSubvolumes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra subvolumes to create";
    };
  };
  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.mainDevice;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "umask=0077"
                    "noatime"
                  ];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "nixcrypt";
                  extraOpenArgs = [ ];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "lvm_pv";
                    vg = "nixvg";
                  };
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        nixvg = {
          type = "lvm_vg";
          lvs = {
            nix = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = lib.genAttrs (
                  [
                    "@"
                    "@home"
                    "@home@.snapshots"
                    "@nix"
                    "@persist"
                  ]
                  ++ cfg.extraSubvolumes
                ) mkSubvolume;
              };
            };
            swap = {
              size = cfg.swapSize;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
    fileSystems."/persist".neededForBoot = true;
  };
}
