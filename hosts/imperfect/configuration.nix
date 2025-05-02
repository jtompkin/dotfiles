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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.postResumeCommands =
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
  #boot.initrd.postDeviceCommands =
  #  lib.mkAfter # sh
  #    ''
  #      echo Starting root wipe...
  #      MNTPOINT=$(mktemp -d)
  #      mount /dev/nixvg/nix "$MNTPOINT" -o subvol=/
  #      btrfs subvolume delete -R "$MNTPOINT/@"
  #      btrfs subvolume snapshot "$MNTPOINT/blank" "$MNTPOINT/@"
  #      echo Finished root wipe
  #    '';

  networking.hostName = "flakey"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = "/persist/passwords/josh";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh = ./home-manager/josh/home.nix;
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/nixos"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
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
      #defaultSession = "sway";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
