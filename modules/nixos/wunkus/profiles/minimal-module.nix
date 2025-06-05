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
  options.wunkus.profiles.minimal.enable = lib.mkEnableOption "minimal Linux config";
  config = mkIf cfg.enable {
    nixpkgs.hostPlatform = config.wunkus.settings.system;
    time.timeZone = mkDefault "America/New_York";
    environment = {
      systemPackages = [ pkgs.vim ];
    };
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    users = {
      users.${username} = {
        isNormalUser = mkDefault true;
        extraGroups = [ "wheel" ];
      };
    };
  };
}
