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
    # time.hardwareClockInLocalTime = mkDefault true;
    boot.loader.efi.canTouchEfiVariables = mkDefault true;
  };
}
