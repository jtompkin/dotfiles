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
