{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.wsl;
  inherit (config.wunkus.settings) username;
  inherit (lib) mkIf mkDefault;
in
{
  options.wunkus.profiles.wsl.enable = lib.mkEnableOption "WSL Linux config";
  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = mkDefault username;
      interop.includePath = mkDefault false;
    };
    services.openssh.enable = mkDefault true;
    environment.systemPackages = [ pkgs.wl-clipboard ];
  };
}
