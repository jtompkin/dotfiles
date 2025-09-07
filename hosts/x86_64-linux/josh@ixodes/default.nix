{
  wunkus = {
    settings = {
      username = "josh";
      userid = 1000;
      system = "x86_64-linux";
    };
    profiles = {
      common.enable = true;
      comfy.enable = true;
    };
    presets = {
      programs = {
        hyprland.enable = true;
        hyprland.wallpaperDir = "/home/josh/Pictures/wallpapers";
        hyprland.defaultWallpaper = "/home/josh/Pictures/Wallpapers/dark_souls_1_01.jpg";
        hyprland.menu = "walker";
        proton.enable = true;
      };
      themes.dark.enable = true;
      services.spotify.enable = true;
    };
  };

  programs = {
    firefox.enable = true;
    git.signing.key = "8C07A97FC369A5F4FCFAC6F1989246B0B9904782";
  };
  services.gpg-agent.sshKeys = [ "B5BE9A6227DB43612DCA51604EF35ABB0FD50B27" ];

  home.stateVersion = "25.05";
}
