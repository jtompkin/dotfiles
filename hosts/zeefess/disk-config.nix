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
            luksSwap = {
              size = "1G";
              content = {
                type = "luks";
                name = "swapcrypt";
                extraOpenArgs = [ ];
                askPassword = true;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  priority = 100;
                  resumeDevice = true;
                };
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "on";
          acltype = "posixacl";
          xattr = "sa";
          relatime = "on";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          "com.sun:auto-snapshot" = "true";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "local" = {
            type = "zfs_fs";
            mountpoint = null;
          };
          "local/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };
          "system" = {
            type = "zfs_fs";
            mountpoint = null;
          };
          "system/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook =
              # sh
              ''
                zfs snapshot rpool/system/root@blank
              '';
          };
          "system/persist" = {
            type = "zfs_fs";
            options.mountpoint = "/persist";
            mountpoint = "/persist";
          };
          "user" = {
            type = "zfs_fs";
            mountpoint = null;
          };
          "user/home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            mountpoint = "/home";
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
