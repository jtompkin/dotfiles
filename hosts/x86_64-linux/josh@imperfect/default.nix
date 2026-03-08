{
  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      common.enable = true;
      comfy.enable = true;
      waylandfyi.enable = true;
    };
    presets = {
      programs = {
        meantToFly.enable = true;
        zshDiy.enable = true;
        neovim = {
          dist = "mini";
          nixosConfigName = "imperfect";
        };
      };
    };
  };
  home.stateVersion = "25.11";
}
