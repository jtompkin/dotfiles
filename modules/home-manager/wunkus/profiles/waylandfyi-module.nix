{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.profiles.waylandfyi;
in
{
  options.wunkus.profiles.waylandfyi = {
    enable = lib.mkEnableOption "profile enabling most wayland.fyi utilities";
    font = lib.mkOption {
      type = lib.hm.types.fontType;
      description = "Font to use for hst (st-wl)";
      default = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font";
        size = 18;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    mornix.programs = {
      hst = {
        enable = mkDefault true;
        finalPackage =
          (config.mornix.programs.hst.package.overrideAttrs {
            patchFlags = [
              "-p1"
              "--ignore-whitespace"
            ];
          }).override
            {
              config.hst.patches = [
                (pkgs.writeText "hst_font.diff" ''
                  diff --git a/config.def.h b/config.def.h
                  index 48d596d..5091fd3 100644
                  --- a/config.def.h
                  +++ b/config.def.h
                  @@ -5,7 +5,7 @@
                    *
                    * font: see http://freedesktop.org/software/fontconfig/fontconfig-user.html
                    */
                  -static char *font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";
                  +static char *font = "${cfg.font.name}:pixelsize=${toString cfg.font.size}:antialias=true:autohint=true";
                   static int borderpx = 2;
                   
                   /*
                '')
                (pkgs.fetchurl {
                  url = "https://st.suckless.org/patches/gruber-darker/st-gruber-darker-0.9.2.diff";
                  hash = "sha256-wwzJrb+zRGCFZPxzYyZH7VT+/uO/NYWbjJrY8C2U+T0=";
                  downloadToTemp = true;
                  postFetch = ''
                    sed -e 's/\+95,33/\+95,35/' \
                      -e '/"gray90", \/\* default foreground colour/d' \
                      -e '/"black", \/\* default background colour/d' \
                      "$downloadedFile" > "$out"
                  '';
                })
              ];
            };
      };
      swiv.enable = mkDefault true;
      neumenu.enable = mkDefault true;
      swall.enable = mkDefault true;
      mojito.enable = mkDefault true;
    };
    home.packages = [ cfg.font.package ];
  };
}
