{
  lib,
  ...
}:
{
  config = {
    lib = {
      custom = import ../../lib lib;
    };
  };
}
