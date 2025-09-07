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

    users.users.${config.wunkus.settings.username}.hashedPasswordFile =
      config.age.secrets.password1.path;
    users.mutableUsers = false;

    services.openssh.enable = mkDefault true;
    networking.networkmanager.enable = mkDefault true;

    boot = {
      loader.systemd-boot.enable = mkDefault true;
      loader.efi.canTouchEfiVariables = mkDefault true;
      supportedFilesystems = [ "ntfs" ];
    };

    i18n.defaultLocale = "en_US.UTF-8";
  };
}
