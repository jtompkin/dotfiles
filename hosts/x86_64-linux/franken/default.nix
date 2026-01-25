{
  networking.hostName = "franken";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal.enable = true;
      wsl.enable = true;
      desktop = {
        enable = true;
        compositors = [ "niri" ];
      };
    };
  };
  programs.dconf.enable = true;

  environment = {
    pathsToLink = [ "/share/zsh" ];
  };

  system.stateVersion = "25.05";
}
