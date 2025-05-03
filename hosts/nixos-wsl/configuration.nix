# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  inputs,
  pkgs,
  ...
}:

{
  imports = with inputs; [
    # include NixOS-WSL modules
    nixos-wsl.nixosModules.default
    home-manager.nixosModules.home-manager
  ];

  environment = {
    systemPackages = with pkgs; [
      vim
    ];
    pathsToLink = [
      "/share/zsh"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  wsl = {
    enable = true;
    defaultUser = "josh";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."josh" = ./home.nix;
  };

  virtualisation = {
    waydroid.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
