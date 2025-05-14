{
  inputs,
  pkgs,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vim
    iterm2
    tigervnc
    utm
    qbittorrent
  ];
  users.users.benoitja = {
    home = "/Users/benoitja";
  };
  home-manager = {
    users."benoitja" = ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      cfg = config;
    };
  };
  nix.settings.experimental-features = "nix-command flakes";
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
