{
  wunkus = {
    settings = {
      username = "deck";
      system = "x86_64-linux";
    };
    profiles = {
      common.enable = true;
      comfy.enable = true;
      gui = {
        enable = true;
        nixgl.enable = true;
      };
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
    zsh.oh-my-zsh.enable = false;
    oh-my-posh.enable = false;
    git.signing.key = "151220FF9D7FB5F6D029E1B2CD8D2FC234AE5981";
  };

  services.gpg-agent.sshKeys = [ "842B7A45D05692CB8C7EDBF0694EFA4941BC592B" ];
  home.stateVersion = "25.05";
}
