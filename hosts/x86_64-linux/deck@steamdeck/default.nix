{
  wunkus = {
    settings = {
      username = "deck";
      system = "x86_64-linux";
    };
    profiles = {
      common.enable = true;
      comfy.enable = true;
      gui.enable = true;
    };
    presets = {
      programs = {
        meantToFly.enable = true;
        zim.enable = true;
        neovim.dist = "mini";
      };
    };
  };
  programs = {
    git.signing.key = "151220FF9D7FB5F6D029E1B2CD8D2FC234AE5981";
  };

  age = {
    identityPaths = [ "/home/deck/.ssh/id_ed25519" ];
    secrets.pypi-token.file = ../../../secrets/pypi-token.age;
  };
  services.gpg-agent.sshKeys = [ "842B7A45D05692CB8C7EDBF0694EFA4941BC592B" ];
  home.stateVersion = "25.05";
}
