{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.services.gpg-agent;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.presets.services.gpg-agent.enable =
    lib.mkEnableOption "gpg-agent service preset configuration";
  config = mkIf cfg.enable {
    programs.gpg.enable = mkDefault true;
    services.gpg-agent = {
      enable = mkDefault true;
      enableSshSupport = mkDefault true;
      pinentry.package = mkDefault pkgs.pinentry-qt;
      defaultCacheTtl = mkDefault 3600;
      defaultCacheTtlSsh = mkDefault 3600;
    };
  };
}
