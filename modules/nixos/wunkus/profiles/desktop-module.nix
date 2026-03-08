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
              patches = [
                (pkgs.writeText "shko_startup.diff" ''
                  diff --git a/config.zig b/config.zig
                  index 5628f04..ff6548e 100644
                  --- a/config.zig
                  +++ b/config.zig
                  @@ -31,6 +31,7 @@ pub const mod = c.SWC_MOD_ALT;
                   pub fn bindings() void {
                       // the main bindings to handle windows
                       _ = c.swc_add_binding(c.SWC_BINDING_KEY, mod, c.XKB_KEY_Return, shko.spawn, @as(?*anyopaque, @ptrCast(@constCast(&shko.terminalCommand))));
                  +    _ = c.swc_add_binding(c.SWC_BINDING_KEY, mod, c.XKB_KEY_d, shko.spawn, @as(?*anyopaque, @ptrCast(@constCast(&shko.swallCommand))));
                       _ = c.swc_add_binding(c.SWC_BINDING_KEY, mod, c.XKB_KEY_BackSpace, shko.closeFocused, null);
                       _ = c.swc_add_binding(c.SWC_BINDING_KEY, mod, c.XKB_KEY_r, shko.spawn, @as(?*anyopaque, @ptrCast(@constCast(&shko.menuCommand))));
                       _ = c.swc_add_binding(c.SWC_BINDING_KEY, mod, c.XKB_KEY_Tab, shko.nextFocus, null);
                  diff --git a/shko.zig b/shko.zig
                  index 84206d3..1ad627c 100644
                  --- a/shko.zig
                  +++ b/shko.zig
                  @@ -44,6 +44,7 @@ var wm = State{};
                   // commands (null-terminated argv expected by execvp)
                   pub const terminalCommand = [_:null]?[*:0]const u8{ config.terminal, null };
                   pub const menuCommand = [_:null]?[*:0]const u8{ config.menu, null };
                  +pub const swallCommand = [_:null]?[*:0]const u8{ "swall", "/home/josh/Pictures/Backgrounds/space.jpg", null };
                   
                   // global viewing variables
                   var xOffset: i32 = 0;
                  @@ -324,7 +325,7 @@ const manager_handler = c.swc_manager{
                   pub fn spawn(data: ?*anyopaque, _: u32, _: u32, state: u32) callconv(.c) void {
                       if (!isKeyPressed(state)) return;
                       const raw_ptr = data orelse return;
                  -    const command: *const [2]?[*:0]const u8 = @ptrCast(@alignCast(raw_ptr));
                  +    const command: *const [16]?[*:0]const u8 = @ptrCast(@alignCast(raw_ptr));
                       const argv: [*c]const [*c]u8 = @ptrCast(@constCast(command));
                   
                       const pid = c.fork();
                '')
              ];
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
