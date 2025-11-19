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
        neovim = {
          dist = "mini";
        };
      };
      themes.dark.enable = true;
    };
  };
  programs = {
    oh-my-posh.enable = false;
    git.signing.key = "7DF0C6189DB5B71EF73118FFB826F212FE4581A5";
  };
  age = {
    identityPaths = [ "/home/josh/.ssh/id_ed25519" ];
    secrets.pypi-token.file = ../../../secrets/pypi-token.age;
  };
  services.gpg-agent.sshKeys = [ "A81E27028CAAA2BB304B86278C44EB1587BA4874" ];
  home.stateVersion = "25.05";
}
