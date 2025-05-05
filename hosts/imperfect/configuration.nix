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
          echo Starting root wipe...
          MNTPOINT=$(mktemp -d)
          mount /dev/nixvg/nix "$MNTPOINT"
          if [[ -e "$MNTPOINT/@" ]]; then
            mkdir -p "$MNTPOINT/old_roots"
            timestamp=$(date --date="@$(stat -c %Y "$MNTPOINT/@")" "+%Y-%m-%-d_%H:%M:%S")
            mv "$MNTPOINT/@" "$MNTPOINT/old_roots/$timestamp"
          fi
          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "$MNTPOINT/$i"
            done
            btrfs subvolume delete "$1"
          }
          for i in $(find "$MNTPOINT/old_roots/" -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
          done
          btrfs subvolume create "$MNTPOINT/@"
          umount "$MNTPOINT"
        '';
  };

  networking = {
    hostName = "imperfect";
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
      ];
    };
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

  system.stateVersion = "25.05";
}
