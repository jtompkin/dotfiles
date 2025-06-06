{ config, lib, ... }:
let
  cfg = config.wunkus.profiles.ephemeral;
in
{
  options = {
    wunkus.profiles.ephemeral.enable = lib.mkEnableOption "ephemeral system config";
    wunkus.profiles.ephemeral.extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra directories to make persistant";
    };
    wunkus.profiles.ephemeral.extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra files to make persistant";
    };
  };
  config = lib.mkIf cfg.enable {
    boot.initrd.postResumeCommands =
      lib.mkAfter # sh
        ''
          echo Starting root wipe...
          MNTPOINT=$(mktemp -d)
          mount ${config.fileSystems."/".device} "$MNTPOINT"
          if [[ -e "$MNTPOINT/@" ]]; then
            mkdir -p "$MNTPOINT/old_roots"
            timestamp=$(date --date="@$(stat -c %Y "$MNTPOINT/@")" "+%Y-%m-%-d_%H:%M:%S")
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

    environment.persistence = {
      "/persist" = {
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
        ] ++ cfg.extraDirectories;
        files = [
          "/etc/machine-id"
        ] ++ cfg.extraFiles;
      };
    };
  };
}
