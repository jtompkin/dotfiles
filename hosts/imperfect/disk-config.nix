# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix
let
  btrfsOptions =
    extra:
    [
      "compress=zstd"
      "noatime"
    ]
    ++ extra;
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
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
                passwordFile = "/tmp/secret.key";
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
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = btrfsOptions [ ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsOptions [ ];
                };
                "@home@.snapshots" = {
                  mountpoint = "/home/.snapshots";
                  mountOptions = btrfsOptions [ ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOptions [ ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = btrfsOptions [ ];
                };
              };
            };
          };
          swap = {
            size = "1G";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
