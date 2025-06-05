{
  networking.hostName = "dualbooty";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      vm.enable = true;
      ephemeral.enable = true;
      dualBooty = {
        enable = true;
        luksUUID = "3831a625-c20c-4663-8e76-8c624632e502";
        espLabel = "SYSTEM";
      };
    };
    hardware."virtualbox-x86_64-linux".enable = true;
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.05";
}
