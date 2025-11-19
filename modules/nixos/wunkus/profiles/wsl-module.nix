{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.profiles.wsl;
  inherit (lib) mkDefault;
in
{
  options.wunkus.profiles.wsl.enable = lib.mkEnableOption "WSL Linux config";
  config = lib.mkIf cfg.enable {
    boot.tmp.useTmpfs = mkDefault true;
    wsl = {
      enable = true;
      defaultUser = mkDefault config.wunkus.settings.username;
      interop.includePath = mkDefault false;
      docker-desktop.enable = mkDefault true;
      extraBin = [
        { src = "/mnt/c/Windows/System32/cmd.exe"; }
        { src = "/mnt/c/Windows/System32/clip.exe"; }
      ];
    };
    services.openssh.enable = mkDefault true;
    environment.systemPackages = [
      pkgs.wl-clipboard
      pkgs.kmod
      pkgs.systemd
    ];
  };
}
