#!/usr/bin/env bash

# Palette {{{

_set_color () {
    local color_name="@gruvbox_$1"
    local color_24_bit=$2
    tmux set-option -g $color_name $color_24_bit
}

# Gruvbox color from gruvbox community
_set_color dark0_hard      '#1d2021'
_set_color dark0           '#282828'
_set_color dark0_soft      '#32302f'
_set_color dark1           '#3c3836'
_set_color dark2           '#504945'
_set_color dark3           '#665c54'
_set_color dark4           '#7c6f64'
_set_color dark4_256       '#7c6f64'
_set_color gray_245        '#928374'
_set_color gray_244        '#928374'
_set_color light0_hard     '#f9f5d7'
_set_color light0          '#fbf1c7'
_set_color light0_soft     '#f2e5bc'
_set_color light1          '#ebdbb2'
_set_color light2          '#d5c4a1'
_set_color light3          '#bdae93'
_set_color light4          '#a89984'
_set_color light4_256      '#a89984'
_set_color bright_red      '#fb4934'
_set_color bright_green    '#b8bb26'
_set_color bright_yellow   '#fabd2f'
_set_color bright_blue     '#83a598'
_set_color bright_purple   '#d3869b'
_set_color bright_aqua     '#8ec07c'
_set_color bright_orange   '#fe8019'
_set_color neutral_red     '#cc241d'
_set_color neutral_green   '#98971a'
_set_color neutral_yellow  '#d79921'
_set_color neutral_blue    '#458588'
_set_color neutral_purple  '#b16286'
_set_color neutral_aqua    '#689d6a'
_set_color neutral_orange  '#d65d0e'
_set_color faded_red       '#9d0006'
_set_color faded_green     '#79740e'
_set_color faded_yellow    '#b57614'
_set_color faded_blue      '#076678'
_set_color faded_purple    '#8f3f71'
_set_color faded_aqua      '#427b58'
_set_color faded_orange    '#af3a03'

# }}}
# Tmux theme {{{

# Xterm
tmux set-option -g default-terminal "xterm-256color"

# Clock
tmux set-option -gF clock-mode-colour "#{@gruvbox_bright_blue}"

# Message infos
tmux set-option -gF message-style "fg=#{@gruvbox_light1},bg=#{@gruvbox_dark2}"

# Pane border
tmux set-option -gF pane-active-border-style "fg=#{@gruvbox_light2}"
tmux set-option -gF pane-border-style "fg=#{@gruvbox_dark1}"

# Pane number display
tmux set-option -gF display-panes-active-colour "#{@gruvbox_light2}"
tmux set-option -gF display-panes-colour "#{@gruvbox_dark1}"

# Popup border
tmux set-option -gF popup-border-style "fg=#{@gruvbox_gray_244}"
tmux set-option -g  popup-border-lines "rounded"

# True color
tmux set-option -ga terminal-features ",*:RGB"

# }}}

# vim:filetype=tmux:foldmethod=marker
