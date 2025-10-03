{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wunkus.presets.programs.go;
in
{
  options.wunkus.presets.programs.go.enable = lib.mkEnableOption "Go preset configuration";
  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = lib.mkDefault true;
      telemetry.mode = "off";
    };
    home.packages = [
      (pkgs.writeShellScriptBin "go-build-release" ''
        die() {
          echo $@
          exit 1
        }

        if [[ $# < 2 ]]; then
          echo usage:
          echo $0 program version
          echo program: Provide the program name string for file naming
          echo version: Provide the version string for file naming
          exit 2
        fi
        if [ ! -f go.mod ]; then
          die Not in a Go project
        fi

        program="$1"
        version="$2"
        release_dir=release/"$version"
        mkdir -p "$release_dir"
        if [ -n "$(ls -A "$release_dir" 2>/dev/null)" ]; then
          die Release directory "$release_dir" not empty. Exiting now.
        fi

        tmp_dir=$(mktemp -d)
        prog_dir=$tmp_dir/"$program"
        mkdir "$prog_dir"
        if [ -f README.md ]; then
          cp README.md "$prog_dir"
        fi
        if [ -f LICENSE ]; then
          cp LICENSE "$prog_dir"
        fi

        os_vals=(linux darwin windows)
        arch_vals=(amd64 arm64)
        for os in ''${os_vals[@]}; do
          for arch in ''${arch_vals[@]}; do
            archive_name="''${program}_''${version}_''${os}_''${arch}.tar.gz"
            set -x
            GOOS=$os GOARCH=$arch ${lib.getExe pkgs.go} build -o "$prog_dir/" .
            set +x
            tar czf "$release_dir/$archive_name" -C "$tmp_dir" .
            find "$tmp_dir" -type f -executable -delete
          done
        done
        rm -rf "$tmp_dir"
        (cd "$release_dir" && sha256sum *.tar.gz >"''${program}_''${version}.sha256sum")
      '')
    ];
  };
}
