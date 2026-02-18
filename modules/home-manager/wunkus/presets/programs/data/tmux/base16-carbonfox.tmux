# Base16 carbonfox
# Scheme author: EdenEast
# Template author: Tinted Theming: (https://github.com/tinted-theming)

# default statusbar colors
set-option -g status-style "fg=#7b7c7e,bg=#252525"

# default window title colors
set-window-option -g window-status-style "fg=#7b7c7e,bg=#252525"

# active window title colors
set-window-option -g window-status-current-style "fg=#08bdba,bg=#252525"

# pane border
set-option -g pane-border-style "fg=#252525"
set-option -g pane-active-border-style "fg=#7b7c7e"

# message text
set-option -g message-style "fg=#b6b8bb,bg=#353535"

# pane number display
set-option -g display-panes-active-colour "#7b7c7e"
set-option -g display-panes-colour "#252525"

# clock
set-window-option -g clock-mode-colour "#78a9ff"

# copy mode highlight
set-window-option -g mode-style "fg=#7b7c7e,bg=#353535"

# bell
set-window-option -g window-status-bell-style "fg=#161616,bg=#ee5396"

# style for window titles with activity
set-window-option -g window-status-activity-style "fg=#f2f4f8,bg=#252525"

# style for command messages
set-option -g message-command-style "fg=#b6b8bb,bg=#353535"

# Optional active/inactive pane state
# BASE16_TMUX_OPTION_ACTIVE is a legacy variable
if-shell '[ "$TINTED_TMUX_OPTION_ACTIVE" = "1" ] || [ "$BASE16_TMUX_OPTION_ACTIVE" = "1" ]' {
  set-window-option -g window-active-style "fg=#f2f4f8,bg=#161616"
  set-window-option -g window-style "fg=#f2f4f8,bg=#252525"
}

# Optional statusbar
# BASE16_TMUX_OPTION_STATUSBAR is a legacy variable
if-shell '[ "$TINTED_TMUX_OPTION_STATUSBAR" = "1" ] || [ "$BASE16_TMUX_OPTION_STATUSBAR" = "1" ]' {
  set-option -g status "on"
  set-option -g status-justify "left"
  set-option -g status-left "#[fg=#f2f4f8,bg=#484848] #S #[fg=#484848,bg=#252525,nobold,noitalics,nounderscore]"
  set-option -g status-left-length "80"
  set-option -g status-left-style none
  set-option -g status-right "#[fg=#353535,bg=#252525 nobold, nounderscore, noitalics]#[fg=#7b7c7e,bg=#353535] %Y-%m-%d  %H:%M #[fg=#f2f4f8,bg=#353535,nobold,noitalics,nounderscore]#[fg=#252525,bg=#f2f4f8] #h "
  set-option -g status-right-length "80"
  set-option -g status-right-style none
  set-window-option -g window-status-current-format "#[fg=#252525,bg=#08bdba,nobold,noitalics,nounderscore]#[fg=#353535,bg=#08bdba] #I #[fg=#353535,bg=#08bdba,bold] #W#{?window_zoomed_flag,*Z,} #[fg=#08bdba,bg=#252525,nobold,noitalics,nounderscore]"
  set-window-option -g window-status-format "#[fg=#252525,bg=#353535,noitalics]#[fg=#b6b8bb,bg=#353535] #I #[fg=#b6b8bb,bg=#353535] #W#{?window_zoomed_flag,*Z,} #[fg=#353535,bg=#252525,noitalics]"
  set-window-option -g window-status-separator ""
}

# vim: set ft=tmux tw=0:
