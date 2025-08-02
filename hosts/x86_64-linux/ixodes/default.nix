{
  networking.hostName = "ixodes";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      ephemeral.enable = true;
      dualBooty.enable = true;
      secure.enable = true;
      nvidia.enable = true;
    };
    disks = {
      dualBooty.enable = true;
    };
    hardware."asusRog-x86_64-linux".enable = true;
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.11";
}
