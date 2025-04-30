{pkgs ? import <nixpkgs> {}}: {
  rstudio = pkgs.callPackage ./rstudio.nix {};
}
