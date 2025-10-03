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
        go.enable = true;
      };
      themes.dark.enable = true;
    };
  };

  programs.oh-my-posh.enable = false;
  programs.git.signing.key = "8C07A97FC369A5F4FCFAC6F1989246B0B9904782";
  services.gpg-agent.sshKeys = [ "B5BE9A6227DB43612DCA51604EF35ABB0FD50B27" ];
  home.stateVersion = "25.05";
}
