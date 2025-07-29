{
  networking.hostName = "secure";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      vm.enable = true;
      ephemeral.enable = true;
      secure.enable = true;
    };
    disks = {
      btrfsEncrypt = {
        enable = true;
        swapSize = "4G";
        mainDevice = "/dev/vda";
      };
    };
    hardware."kvm-x86_64-linux".enable = true;
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.05";
}
