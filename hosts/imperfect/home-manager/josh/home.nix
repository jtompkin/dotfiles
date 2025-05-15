{
  inputs,
  extraModulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (extraModulesPath + "/home-manager/neovim/neovim.nix")
  ];
  home = {
    stateVersion = "24.11";
    username = "josh";
    homeDirectory = "/home/josh";
    packages = with pkgs; [
      htop
    ];
  };

  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        ls = "ls --color=tty --group-directories-first";
        l = "ls -lAhpv";
        la = "ls -lahpv";
        ll = "ls -lhpv";
        info = "info --vi-keys";
        fd = "fd --one-file-system";
      };
      oh-my-zsh = {
        enable = true;
        theme = "gallifrey";
        plugins = [
          "git"
          "sudo"
        ];
      };
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];
    };
    oh-my-posh = {
      enable = true;
      useTheme = "space";
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      shell = lib.getExe pkgs.zsh;
      extraConfig = # tmux
        ''
          set -g status-position top
          bind-key C-t set status
        '';
      plugins = with pkgs.tmuxPlugins; [
        sensible
        pain-control
      ];
    };
    git = {
      enable = true;
      delta.enable = true;
      userName = "jtompkin";
      userEmail = "jtompkin-dev@pm.me";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
    fzf = {
      enable = true;
      changeDirWidgetCommand = "";
    };

    fd.enable = true;
    ripgrep.enable = true;
    home-manager.enable = true;
  };
}
