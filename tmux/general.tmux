#!/usr/bin/env bash

# Title {{{

# Terminal title
tmux setoption -g set-titles on
tmux setoption -g set-titles-string '❐ #S ● #I #W'

# }}}
# Window {{{

# Renumber windows when a window is closed
tmux set-option -g renumber-windows on

# Rename window to reflect current program
tmux set-option -g automatic-rename on

# Window base index
tmux set-option -g base-index 1

# }}}
# Pane {{{

# Pane base index
tmux set-option -g pane-base-index 1

# }}}
# Misc {{{

# Mouse
tmux set-option -g mouse on

# }}}

# vim:filetype=tmux:foldmethod=marker
