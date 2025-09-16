{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
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
  config = mkIf cfg.enable {
    boot.initrd =
      let
        script = ''
          echo Starting root wipe...
          MNTPOINT=$(mktemp -d)
          mount -t btrfs ${config.fileSystems."/".device} "$MNTPOINT"
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
          echo Finished root wipe...
        '';
      in
      {
        postResumeCommands = mkIf (!config.boot.initrd.systemd.enable) (lib.mkAfter script);
        systemd = mkIf config.boot.initrd.systemd.enable {
          services.btrfs-rollback = {
            description = "Rollback BTRFS filesystem to blank snapshot";
            wantedBy = [ "initrd.target" ];
            after = [ "initrd-root-device.target" ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            inherit script;
          };
          storePaths = [
            pkgs.btrfs-progs
            pkgs.coreutils
            pkgs.util-linux
          ];
        };
      };

    environment.persistence = {
      "/persist" = {
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/sbctl"
          "/var/lib/systemd"
          "/etc/ssh"
          "/etc/NetworkManager/system-connections"
        ]
        ++ cfg.extraDirectories;
        files = [
          "/etc/machine-id"
        ]
        ++ cfg.extraFiles;
      };
    };
    age.identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/etc/ssh/ssh_host_rsa_key"
    ];
  };
}
