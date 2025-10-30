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
        zim.enable = true;
        neovim.plugins.plugins.render-markdown-nvim.enable = true;
      };
      themes.dark.enable = true;
    };
  };
  programs = {
    zsh.oh-my-zsh.enable = false;
    oh-my-posh.enable = false;
    # git.signing.key = "8C07A97FC369A5F4FCFAC6F1989246B0B9904782";
    git.signing.key = "151220FF9D7FB5F6D029E1B2CD8D2FC234AE5981";
  };
  services.gpg-agent.sshKeys = [ "842B7A45D05692CB8C7EDBF0694EFA4941BC592B" ];
  home.stateVersion = "25.05";
}
