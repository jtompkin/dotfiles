{
  inputs,
  lib,
  pkgs,
  cfg,
  ...
}:
{
  home = {
    username = "benoitja";
    homeDirectory = "/Users/benoitja";
    stateVersion = "24.11";
    packages = with pkgs; [
      entr
      dust
      coreutils
      inputs.self.packages.${cfg.nixpkgs.hostPlatform.system}.goclacker
    ];
  };
  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        hm = "home-manager";
        cat = "bat --paging=never";
        ls = "ls --color=tty --group-directories-first";
        l = "ls -lAhpv";
        la = "ls -lahpv";
        ll = "ls -lhpv";
        info = "info --vi-keys";
        fd = "fd --one-file-system";
      };
      initContent = ''
        eval "$(batpipe)"
        alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
      '';
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
      enableZshIntegration = true;
      useTheme = "space";
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      shell = lib.getExe pkgs.zsh;
      extraConfig = ''
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
        init = {
          defaultBranch = "main";
        };
      };
    };

    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
        batpipe
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetCommand = "";
    };

    neovim = inputs.self.configs.${cfg.nixpkgs.hostPlatform.system}.neovim.full;

    fd.enable = true;
    ripgrep.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
  };
  xdg = {
    enable = true;
    configFile = {
      stylua.source = ../../dotfiles/.config/stylua;
    };
  };
}
