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
      gaimin = {
        enable = true;
        emulate.enable = true;
      };
      media.enable = true;
    };
    presets = {
      programs = {
        hyprland = {
          enable = true;
          nvidia = true;
          asus = true;
          wallpaperDir = "/home/josh/Pictures/Wallpapers";
          defaultWallpaper = "/home/josh/Pictures/Wallpapers/primes_twilight_10000.jpg";
          lockBackground = "/home/josh/Pictures/Wallpapers/MVIC_sunset_scan_of_Pluto.jpg";
          defaultApps.terminal.name = "kitty";
          defaultApps.appLauncher.name = "fuzzel";
        };
        zim.enable = true;
        meantToFly.enable = true;
        niri = {
          enable = true;
          wallpaperDir = "/home/josh/Picture/Wallpapers";
        };
        proton.enable = true;
        discord.enable = true;
      };
      themes.dark.enable = true;
      services.spotify.enable = true;
    };
  };

  programs = {
    zsh.oh-my-zsh.enable = false;
    git.signing.key = "8C07A97FC369A5F4FCFAC6F1989246B0B9904782";
    noctalia-shell.enable = false;
    oh-my-posh.enable = false;
  };
  services.gpg-agent.sshKeys = [ "B5BE9A6227DB43612DCA51604EF35ABB0FD50B27" ];

  home.stateVersion = "25.05";
}
