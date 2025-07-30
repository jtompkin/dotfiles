{
  networking.hostName = "ixodes";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      vm.enable = true;
      ephemeral.enable = true;
      dualBooty.enable = true;
      secure.enable = true;

      common.enable = true;
      comfy.enable = true;
    };
    disks = {
      dualBooty.enable = true;
    };
    hardware."kvm-x86_64-linux".enable = true;
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.11";
}
