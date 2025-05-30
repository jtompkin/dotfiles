rec {
  networking.hostName = "imperfect";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      vm.enable = true;
    };
    disks = {
      btrfsEncrypt.enable = true;
      btrfsEcrypt.swapSize = "4G";
    };
  };

  home-manager.users.${wunkus.settings.username} = {
    wunkus = {
      settings = {
        inherit (wunkus.settings) username system;
        host = networking.hostname;
      };
      profiles = {
        common.enable = true;
      };
    };
    home.stateVersion = "25.05";
  };

  time.timeZone = "America/New_York";

  console.useXkbConfig = true;
  services.xserver.xkb.options = "caps:swapescape";

  system.stateVersion = "25.05";
}
