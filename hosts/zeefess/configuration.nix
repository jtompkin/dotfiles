# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = with inputs; [
    disko.nixosModules.disko
    home-manager.nixosModules.home-manager
    impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.postResumeCommands =
      lib.mkAfter # sh
        ''
          zfs rollback -r zroot/local/root@blank
        '';
  };

  networking = {
    hostId = "ea51e3e9";
    hostName = "zeefess";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.josh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = lib.mkDefault (lib.fileContents ./password.sha512);
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh = ./home-manager/josh/home.nix;
  };

  environment = {
    systemPackages = with pkgs; [
      vim
    ];
    persistence."/persist" = {
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/waydroid"
      ];
    };
  };

  services = {
    openssh.enable = true;
  };

  system.stateVersion = "25.05";
}
