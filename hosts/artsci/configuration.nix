{
  inputs,
  pkgs,
  ...
}: {
  #inports = [
  #  inputs.home-manager.darwinModules.home-manager
  #];
  environment.systemPackages = with pkgs; [
    vim
    iterm2
    tigervnc
    (rstudioWrapper.override {
      packages = with rPackages; [
        tidyverse
      ];
    })
  ];
  users.users.benoitja = {
    home = "/Users/benoitja";
  };
  #home-manager = {
  #  useGlobalPkgs = true;
  #  useUserPackages = true;
  #  users.benoitja = ./home.nix;
  #  extraSpecialArgs = {inherit inputs;};
  #};
  nix.settings.experimental-features = "nix-command flakes";
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
