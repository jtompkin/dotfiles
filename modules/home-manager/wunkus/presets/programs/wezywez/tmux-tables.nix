lib: {
  tmux = (
    [
      {
        key = "\\";
        action = "SplitHorizontal{domain = 'CurrentPaneDomain'}";
      }
      {
        key = "-";
        action = "SplitVertical{domain = 'CurrentPaneDomain'}";
      }
      {
        key = "h";
        action = "ActivatePaneDirection'Left'";
      }
      {
        key = "j";
        action = "ActivatePaneDirection'Down'";
      }
      {
        key = "k";
        action = "ActivatePaneDirection'Up'";
      }
      {
        key = "l";
        action = "ActivatePaneDirection'Right'";
      }
      {
        key = "x";
        action = "CloseCurrentPane{confirm = true}";
      }
      {
        key = "c";
        action = "SpawnTab'CurrentPaneDomain'";
      }
      {
        key = ".";
        action = "MoveTabRelative(1)";
      }
      {
        key = ",";
        action = "MoveTabRelative(-1)";
      }
      {
        key = "n";
        action = "ActivateTabRelative(1)";
      }
      {
        key = "p";
        action = "ActivateTabRelative(-1)";
      }
      {
        key = "&";
        mods = [ "SHIFT" ];
        action = "CloseCurrentTab{confirm = true}";
      }
      {
        key = "w";
        action = "ShowTabNavigator";
      }
      {
        key = "s";
        action = "ShowLauncher";
      }
      {
        key = "r";
        action = "ActivateKeyTable{name = 'tmux_repeat', one_shot = false}";
      }
      {
        key = "Escape";
        action = "PopKeyTable";
      }
      {
        key = "q";
        action = "PopKeyTable";
      }
      {
        key = "B";
        mods = [
          "CTRL"
          "SHIFT"
        ];
        action = "Multiple{wezterm.action.SendKey{key = 'B', mods = 'CTRL|SHIFT'}, wezterm.action.PopKeyTable}";
      }
    ]
    ++ map (num: {
      key = toString num;
      action = "ActivateTab(${toString (num - 1)})";
    }) (lib.range 0 9)
  );
  tmux_repeat = [
    {
      key = "h";
      action = "AdjustPaneSize{'Left', 1}";
    }
    {
      key = "j";
      action = "AdjustPaneSize{'Down', 1}";
    }
    {
      key = "k";
      action = "AdjustPaneSize{'Up', 1}";
    }
    {
      key = "l";
      action = "AdjustPaneSize{'Right', 1}";
    }
    {
      key = "h";
      mods = [ "CTRL" ];
      action = "ActivatePaneDirection'Left'";
    }
    {
      key = "j";
      mods = [ "CTRL" ];
      action = "ActivatePaneDirection'Down'";
    }
    {
      key = "k";
      mods = [ "CTRL" ];
      action = "ActivatePaneDirection'Up'";
    }
    {
      key = "l";
      mods = [ "CTRL" ];
      action = "ActivatePaneDirection'Right'";
    }
    {
      key = ",";
      action = "MoveTabRelative(-1)";
    }
    {
      key = ".";
      action = "MoveTabRelative(1)";
    }
    {
      key = "Escape";
      action = "PopKeyTable";
    }
    {
      key = "q";
      action = "PopKeyTable";
    }
  ];
}
