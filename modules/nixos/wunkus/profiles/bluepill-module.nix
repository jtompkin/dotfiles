{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.profiles.bluepill;
in
{
  options = {
    wunkus.profiles.bluepill.enable = mkEnableOption "applications for creating/managing virtual machines";
  };
  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = mkDefault true;
        qemu = {
          swtpm.enable = mkDefault true;
          ovmf.enable = mkDefault true;
        };
      };
    };
    programs = {
      virt-manager.enable = mkDefault true;
    };
    users.users.${config.wunkus.settings.username}.extraGroups = [ "libvirtd" ];
    wunkus.profiles.ephemeral.extraDirectories = [ "/var/lib/libvirt/images" ];
  };
}
