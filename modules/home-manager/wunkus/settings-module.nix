{ lib, config, ... }:
{
  options.wunkus.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username of the this user";
    };
    userid = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      description = "User ID of this user. Used to find Age encrypted user secrets without parameter expansion";
      default = null;
    };
    system = lib.mkOption {
      type = lib.types.enum config.lib.dotfiles.const.allSystems;
      description = "System to build this configuration on";
    };
  };
}
