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

    users.users.${config.wunkus.settings.username}.hashedPassword = mkDefault (
      lib.fileContents ./data/password.sha512
    );

    # time.hardwareClockInLocalTime = mkDefault true;
    services.openssh.enable = mkDefault true;
    networking.networkmanager.enable = mkDefault true;

    boot.loader.efi.canTouchEfiVariables = mkDefault true;

    i18n.defaultLocale = "en_US.UTF-8";
  };
}
