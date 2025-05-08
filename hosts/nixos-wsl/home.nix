{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home = {
    username = "josh";
    homeDirectory = "/home/josh";
    stateVersion = "24.11";
    packages = with pkgs; [
      entr
      dust
    ];
    file = {
    };
    sessionVariables = {
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        cat = "bat --paging=never";
        ls = "ls --color=tty --group-directories-first";
        l = "ls -lAhpv";
        la = "ls -lahpv";
        ll = "ls -lhpv";
        info = "info --vi-keys";
        fd = "fd --one-file-system";
        ssh-vm = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
        scp-vm = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
        rebuild = "nixos-rebuild switch --flake github:jtompkin/dotfiles#nixos --use-remote-sudo";
      };
      initContent = # sh
        ''
          eval "$(batpipe)"
          alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
        '';
      oh-my-zsh = {
        enable = true;
        theme = "gallifrey";
        plugins = [
          "git"
          "sudo"
          "direnv"
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

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    oh-my-posh = {
      enable = false;
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
      extraConfig = # sh
        ''
          set -g status-position top
          bind-key C-t set status
          set-option -a terminal-features 'xterm-256color:RGB'
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
      signing = {
        signByDefault = true;
        key = "8C07A97FC369A5F4FCFAC6F1989246B0B9904782";
      };
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
      changeDirWidgetCommand = "";
    };

    gpg.enable = true;

    neovim = inputs.my-apps.configs."x86_64-linux".neovim.full;

    fd.enable = true;
    ripgrep.enable = true;
    home-manager.enable = true;
  };

  services = {
    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-qt;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      sshKeys = [
        "B5BE9A6227DB43612DCA51604EF35ABB0FD50B27"
      ];
    };
  };

  xdg = {
    enable = true;
    configFile = {
      stylua.source = ../../dotfiles/.config/stylua;
    };
  };
}
