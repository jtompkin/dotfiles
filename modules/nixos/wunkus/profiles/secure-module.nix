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
    environment.systemPackages = [ pkgs.sbctl ];
    wunkus.profiles.ephemeral.extraDirectories = [ config.boot.lanzaboote.pkiBundle ];
    boot = {
      loader.systemd-boot.enable = mkForce false;
      lanzaboote = {
        enable = mkDefault true;
        pkiBundle = mkDefault "/var/lib/sbctl";
      };
    };
  };
}
