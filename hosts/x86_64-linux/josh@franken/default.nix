{
  wunkus = {
    settings = {
      username = "josh";
      system = "x86_64-linux";
    };
    profiles = {
      common.enable = true;
      comfy.enable = true;
    };
    presets = {
      programs = {
        meantToFly.enable = true;
        zshDiy.enable = true;
        neovim = {
          dist = "mini";
          nixosConfigName = "franken";
        };
        kitty.enable = true;
        niri = {
          enable = true;
          noctalia.enable = true;
          syncClipboard = true;
          defaultApps = {
            terminal.name = "kitty";
          };
        };
      };
      themes.stylish.enable = true;
    };
  };
  programs = {
    git.signing.key = "1512 20FF 9D7F B5F6 D029  E1B2 CD8D 2FC2 34AE 5981";
    gpg.settings.default-key = "4749 D691 0BEC 9978 DEE7  F700 ABD5 BA88 1F98 BDF3";
  };
  age = {
    identityPaths = [ "/home/josh/.ssh/id_ed25519" ];
    secrets.pypi-token.file = ../../../secrets/pypi-token.age;
  };
  services.gpg-agent.sshKeys = [ "842B7A45D05692CB8C7EDBF0694EFA4941BC592B" ];
  home.stateVersion = "25.05";
}
