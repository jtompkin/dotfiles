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
  options.wunkus.profiles.dualBooty = {
    enable = lib.mkEnableOption "dual boot with windows profile";
  };
  config = mkIf cfg.enable {
    time.hardwareClockInLocalTime = mkDefault true;
    boot = {
      loader = {
        systemd-boot = {
          enable = mkDefault true;
          xbootldrMountPoint = mkDefault "/boot";
        };
        efi = {
          canTouchEfiVariables = mkDefault true;
          efiSysMountPoint = mkDefault "/efi";
        };
      };
      initrd.luks.devices."nixcrypt" = {
        device = "/dev/disk/by-label/nixcrypt";
        allowDiscards = true;
      };
    };
  };
}
