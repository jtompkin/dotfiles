{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  goclacker = (import pkgs/goclacker { pkgs = pkgs; }).goclacker;
in
{
  home = {
    username = "deck";
    homeDirectory = "/home/deck";

    stateVersion = "24.11";

    packages = with pkgs; [
      entr # Dependency for batwatch
      xsel
      xclip
      dust
      nix-index
      nerd-fonts.meslo-lg
      waydroid

      goclacker
      (config.lib.nixGL.wrap (
        rstudioWrapper.override {
          packages = with rPackages; [
            # R packages to be installed
            tidyverse
          ];
        }
      ))
    ];

    file = {
    };

    sessionVariables = {
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      shellAliases = {
        hm = "home-manager";
        hmsw = "home-manager --flake 'github:jtompkin/dotfiles#deck' switch";
        cat = "bat --paging=never";
        ls = "ls --color=tty --group-directories-first";
        l = "ls -lAhpv";
        la = "ls -lahpv";
        ll = "ls -lhpv";
        info = "info --vi-keys";
        ssh-vm = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
        scp-vm = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
      };
      initContent =
        # sh
        ''
          eval "$(batpipe)"
          alias -g -- --belp='--help 2>&1 | bat --language=help --style=plain'
          path+="$HOME/.cargo/bin"
        '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "direnv"
          "archlinux"
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

    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetCommand = "";
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
      userEmail = "jtompkin-dev@pm.me";
      userName = "jtompkin";
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

    go = {
      enable = true;
      telemetry.mode = "off";
    };

    alacritty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.alacritty;
      theme = "carbonfox";
      settings = {
        terminal.shell = lib.getExe pkgs.zsh;
        font.normal = {
          family = "MesloLGS Nerd Font";
          style = "Regular";
        };
      };
    };

    mpv = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.mpv;
    };

    neovim = import ../../configs/apps/neovim/full { inherit pkgs; };
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
      sshKeys = [
        "B5BE9A6227DB43612DCA51604EF35ABB0FD50B27"
      ];
    };
  };

  fonts = {
    fontconfig.enable = true;
  };

  xdg = {
    desktopEntries = {
      RStudio = {
        name = "RStudio";
        genericName = "IDE";
        categories = [
          "Development"
          "IDE"
        ];
        comment = "Integrated development environment for the R programming language.";
        icon = "rstudio";
        exec = "rstudio";
        terminal = false;
        type = "Application";
      };
    };
  };

  nixGL = {
    packages = inputs.nixgl.packages;
    installScripts = [ "mesa" ];
  };
}
