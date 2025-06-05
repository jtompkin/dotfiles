{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.dualBooty;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.dualBooty.enable = lib.mkEnableOption "dual boot with windows profile";
  config = mkIf cfg.enable {
    time.hardwareClockInLocalTime = mkDefault true;
    boot = {
      loader = {
        systemd-boot = {
          enable = mkDefault true;
          xbootldrMountPoint = "/boot";
        };
        efi = {
          canTouchEfiVariables = mkDefault true;
          efiSysMountPoint = "/efi";
        };
      };
      initrd.luks.devices."nixcrypt" = {
        device = mkDefault (abort "Must set luks device path");
        allowDiscards = true;
      };
      postResumeCommands =
        lib.mkAfter # sh
          ''
            echo Starting root wipe...
            MNTPOINT=$(mktemp -d)
            mount /dev/nixvg/nix "$MNTPOINT"
            if [[ -e "$MNTPOINT/@" ]]; then
              mkdir -p "$MNTPOINT/old_roots"
              timestamp=$(date --date="@$(stat -c %Y "$MNTPOINT/@")" "+%Y-%m-%d_%H:%M:%S")
              mv "$MNTPOINT/@" "$MNTPOINT/old_roots/$timestamp"
            fi
            delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "$MNTPOINT/$i"
              done
              btrfs subvolume delete "$1"
            }
            for i in $(find "$MNTPOINT/old_roots/" -maxdepth 1 -mtime +30); do
              delete_subvolume_recursively "$i"
            done
            btrfs subvolume create "$MNTPOINT/@"
            umount "$MNTPOINT"
          '';
    };
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "compress=zstd"
        ];
      };

      "/efi" = {
        device = "/dev/disk/by-label/SYSTEM";
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

      "/home" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd"
        ];
      };

      "/home/.snapshots" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=@home@.snapshots"
          "compress=zstd"
        ];
      };

      "/nix" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
          "compress=zstd"
        ];
        neededForBoot = true;
      };

      "/persist" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [
          "subvol=@persist"
          "compress=zstd"
        ];
        neededForBoot = true;
      };
    };
  };
}
