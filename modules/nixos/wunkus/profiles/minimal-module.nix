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
  options.wunkus.profiles.minimal = {
    enable = lib.mkEnableOption "minimal Linux config";
    passwords = {
      enable = lib.mkEnableOption "Password configuration for default user";
      secretName = lib.mkOption {
        type = lib.types.str;
        default = "password-01";
        description = "Name of age encrypted secret storing hashed password";
      };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs.hostPlatform = config.wunkus.settings.system;
    time.timeZone = mkDefault "America/New_York";
    environment = {
      systemPackages = with pkgs; [
        vim
        file
      ];
    };
    users = {
      users.${username} = {
        isNormalUser = mkDefault true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        hashedPasswordFile =
          lib.mkIf cfg.passwords.enable
            config.age.secrets.${cfg.passwords.secretName}.path;
      };
    };
  };
}
