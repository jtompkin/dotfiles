{
  config,
  lib,
  ...
}:
let
  cfg = config.wunkus.presets.programs.meantToFly;
in
{
  options.wunkus.presets.programs.meantToFly = {
    enable = lib.mkEnableOption "starship preset configuration";
  };
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = lib.mkDefault true;
      settings = {
        format = lib.concatStrings [
          "$os"
          "$username"
          "$hostname"
          "$shell"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$golang"
          "$nix_shell"
          "$character"
        ];
        os = {
          disabled = false;
          style = "bright-cyan";
          symbols = {
            Windows = "󰨡  ";
            NixOS = "  ";
          };
        };
        shell = {
          disabled = false;
          style = "bright-cyan";
          bash_indicator = "β";
          zsh_indicator = "ζ";
          nu_indicator = "ν";
          powershell_indicator = " ";
        };
        nix_shell = {
          symbol = " ";
          heuristic = true;
          impure_msg = "";
        };
        directory = {
          style = "green";
        };
        golang = {
          symbol = " ";
        };
        character = {
          success_symbol = "[❯](#FFD54F)";
        };
      };
    };
  };
}
