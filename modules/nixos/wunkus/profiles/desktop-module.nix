{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.wunkus.profiles.desktop;
  sddm-astronaut-custom =
    let
      imgStorePath = "${./data/desktop/MVIC_sunset_scan_of_Pluto.jpg}";
      backgroundsDir = "$out/share/sddm/themes/sddm-astronaut-theme/Backgrounds";
    in
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "Backgrounds/${baseNameOf imgStorePath}";
      };
    }).overrideAttrs
      (prevAttrs: {
        installPhase = prevAttrs.installPhase + ''
          chmod u+w ${backgroundsDir}
          cp ${imgStorePath} ${backgroundsDir}
        '';
      });
in
{
  options.wunkus.profiles.desktop = {
    enable = mkEnableOption "desktop system configuration";
    spotify.enable = mkEnableOption "open ports required for Spotify";
    displayManager.enable = mkEnableOption "display manager system configuration";
    compositors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "hyprland"
          "niri"
          "hevel"
          "shko"
        ]
      );
      default = [ ];
      description = "Name of the Wayland compositors to build configurations for";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      hyprland = mkIf (lib.elem "hyprland" cfg.compositors) {
        enable = mkDefault true;
        withUWSM = mkDefault true;
        xwayland.enable = mkDefault true;
      };
      niri = mkIf (lib.elem "niri" cfg.compositors) {
        enable = mkDefault true;
        package = mkDefault pkgs.niri-patched;
      };
    };
    mornix.programs = lib.mkMerge [
      (lib.mkIf (lib.elem "shko" cfg.compositors) {
        neuswc.enable = mkDefault true;
        shko = {
          enable = mkDefault true;
          finalPackage = config.mornix.programs.shko.package.override {
            config.shko = {
              conf = pkgs.runCommand "shko_config.zig" { } ''
                sed -E \
                  -e 's/(pub const terminal = ").*(";)/\1st-wl\2/' \
                  ${config.mornix.programs.shko.package.src}/config.zig > $out
              '';
            };
          };
        };
      })
      (lib.mkIf (lib.elem "hevel" cfg.compositors) {
        neuswc.enable = mkDefault true;
        hevel = {
          enable = mkDefault true;
          finalPackage = config.mornix.programs.hevel.package.override {
            config.hevel.patches = [
              (pkgs.writeText "alt_hevel.diff" ''
                diff --git a/hevel.c b/hevel.c
                index ab2a244..98a5736 100644
                --- a/hevel.c
                +++ b/hevel.c
                @@ -1389,7 +1389,7 @@ main(void)
                 	
                 	maybe_enable_nein_cursor_theme();
                 	
                -	swc_add_binding(SWC_BINDING_KEY, SWC_MOD_LOGO | SWC_MOD_SHIFT,
                +	swc_add_binding(SWC_BINDING_KEY, SWC_MOD_ALT | SWC_MOD_SHIFT,
                 	                XKB_KEY_q, quit, NULL);
                 	                
                 	/* we can bind mouse buttons using SWC_MOD_ANY */
              '')
            ];
          };
        };
      })
    ];
    niri-flake.cache.enable = false;
    environment = {
      systemPackages = lib.mkMerge [
        (mkIf cfg.displayManager.enable [ sddm-astronaut-custom ])
      ];
      pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
    };
    # security.rtkit.enable = mkDefault true;
    # hardware.bluetooth.enable = mkDefault true;
    networking = mkIf cfg.spotify.enable {
      firewall = {
        allowedTCPPorts = [ 57621 ];
        allowedUDPPorts = [ 5353 ];
      };
      # Workaround for: https://github.com/Spotifyd/spotifyd/issues/1358
      hosts = {
        "0.0.0.0" = [ "apresolve.spotify.com" ];
      };
    };
    services.gvfs = {
      enable = mkDefault true;
      package = pkgs.gvfs;
    };
    # services = {
    #   blueman.enable = mkDefault true;
    #   gvfs.enable = mkDefault true;
    #   displayManager.sddm = mkIf cfg.displayManager.enable {
    #     enable = mkDefault true;
    #     package = mkDefault pkgs.kdePackages.sddm;
    #     wayland.enable = mkDefault true;
    #     autoNumlock = mkDefault true;
    #     extraPackages = [ pkgs.kdePackages.qtmultimedia ];
    #     theme = mkDefault "sddm-astronaut-theme";
    #   };
    # };
  };
}
