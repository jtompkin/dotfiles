{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    ;
  cfg = config.wunkus.profiles.secure;
in
{
  options = {
    wunkus.profiles.secure.enable = mkEnableOption "secure system config";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sbctl
      pkgs.tpm2-tss
    ];
    boot = {
      loader.systemd-boot.enable = mkForce false;
      initrd.systemd.enable = mkDefault true;
      lanzaboote = {
        enable = mkDefault true;
        pkiBundle = mkDefault "/var/lib/sbctl";
        configurationLimit = 10;
      };
    };
  };
}
