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
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
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
            mountpoint = "none";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook =
              # sh
              ''
                zfs snapshot zroot/local/root@blank
              '';
          };
          "local/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };
          "safe" = {
            type = "zfs_fs";
            mountpoint = "none";
          };
          "safe/home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            mountpoint = "/home";
          };
          "safe/persist" = {
            type = "zfs_fs";
            options.mountpoint = "/persist";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
