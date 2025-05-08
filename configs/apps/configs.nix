{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
in
mkTransposedPerSystemModule {
  name = "configs";
  option = mkOption {
    type = types.attrs;
    default = { };
  };
  file = ./configs.nix;
}
