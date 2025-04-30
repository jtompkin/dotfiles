{pkgs ? import <nixpkgs> {}}: {
  goclacker = pkgs.callPackage ./goclacker.nix {};
}
