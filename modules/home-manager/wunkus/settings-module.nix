{ lib, config, ... }:
{
  options.wunkus.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username of the big-boss-man of this system";
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of this system";
    };
    system = lib.mkOption {
      type = lib.types.enum config.lib.lib.allSystems;
      description = "System to build this configuration on";
    };
  };
}
