{
  networking.hostName = "ixodes";
  # Set by secure module once enabled after install
  boot.initrd.systemd.enable = true;
  # Fix user password after install
  users.mutableUsers = true;
  users.users."josh".hashedPasswordFile = null;
  users.users."josh".initialPassword = "ds";
  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      ephemeral = {
        enable = true;
        # Remove once mutableUsers = false
        extraFiles = [
          "/etc/passwd"
          "/etc/group"
        ];
      };
      dualBooty.enable = true;
      # Enable after install
      # secure.enable = true;
      nvidia.enable = true;
      desktop = {
        enable = true;
        spotify.enable = true;
        displayManager.enable = true;
        fileManager.enable = true;
        compositors = [
          "hyprland"
        ];
      };
      vapor.enable = true;
      snappy.enable = true;
      laptop = {
        enable = true;
        asus = true;
      };
      bluepill.enable = true;
      windy = {
        enable = true;
        client = "qbittorrent";
      };
    };
    disks.btrfsEncrypt = {
      enable = true;
      swapSize = "12G";
      mainDevice = "/dev/nvme0n1";
    };
    hardware."asusRog-x86_64-linux".enable = true;
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.11";
}
