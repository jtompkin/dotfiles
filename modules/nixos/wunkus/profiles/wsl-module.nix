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
      useWindowsDriver = mkDefault true;
      defaultUser = mkDefault config.wunkus.settings.username;
      interop.includePath = mkDefault false;
      docker-desktop.enable = mkDefault false;
      extraBin = [
        { src = "/mnt/c/Windows/System32/cmd.exe"; }
        { src = "/mnt/c/Program Files/PowerShell/7/pwsh.exe"; }
        { src = "/mnt/c/Windows/System32/clip.exe"; }
      ];
    };
    users.users.${config.wunkus.settings.username}.extraGroups = [
      "video"
    ];
    services.openssh.enable = mkDefault true;
    environment = {
      sessionVariables = {
        LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
        GALLIUM_DRIVER = "d3d12";
      };
      systemPackages = [
        pkgs.kmod
        pkgs.systemd
      ];
    };
  };
}
