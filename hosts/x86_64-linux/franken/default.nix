{
  networking.hostName = "franken";

  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      minimal = {
        enable = true;
        passwords = {
          enable = true;
          secretName = "password-01";
        };
      };
      wsl.enable = true;
      desktop = {
        enable = true;
        compositors = [ "niri" ];
      };
    };
  };
  programs.dconf.enable = true;
  users.mutableUsers = false;

  environment = {
    pathsToLink = [ "/share/zsh" ];
  };
  age = {
    secrets.password-01.file = ../../../secrets/password-01.age;
  };
  system.stateVersion = "25.05";
}
