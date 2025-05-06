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
    hostName = "zeefess";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

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

  programs = {
    sway.enable = true;
  };

  services = {
    openssh.enable = true;

    snapper = {
      configs = {
        home = {
          SUBVOLUME = "/home";
          ALLOW_USERS = [ "josh" ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
        };
      };
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };
    };
  };

  virtualisation = {
    waydroid.enable = true;
  };

  system.stateVersion = "25.05";
}
