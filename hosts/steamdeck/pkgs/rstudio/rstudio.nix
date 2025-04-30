{
  rstudioWrapper,
  rPkgs ? [],
  ...
}:
rstudioWrapper.override {packages = rPkgs;}
