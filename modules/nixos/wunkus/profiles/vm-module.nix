{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wunkus.profiles.minimal;
  inherit (config.wunkus.settings) username;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.vm.enable = lib.mkEnableOption "Linux vm config";
  config = mkIf cfg.enable {
    boot = {
      loader = {
        #systemd-boot.enable = mkDefault true;
        efi.canTouchEfiVariables = mkDefault true;
      };
    };
    users = {
      mutableUsers = mkDefault true;
      users.${username} = {
        hashedPassword = mkDefault (lib.fileContents ./data/password.sha512);
      };
    };
    services.openssh.enable = true;
    networking.networkmanager.enable = mkDefault true;
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
