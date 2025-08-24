{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.wunkus.profiles.laptop;
in
{
  options = {
    wunkus.profiles.laptop.enable = mkEnableOption "laptop profile config";
    wunkus.profiles.laptop.asus = mkEnableOption "Asus laptop specific config";
  };
  config = mkIf cfg.enable {
    powerManagement.enable = mkDefault true;
    services = {
      tlp.enable = mkDefault true;
      thermald.enable = mkDefault true;
      logind = {
        lidSwitch = mkDefault "suspend";
        lidSwitchDocked = mkDefault "ignore";
      };
      asusd = mkIf cfg.asus {
        enable = mkDefault true;
        enableUserService = mkDefault true;
      };
    };
  };
}
