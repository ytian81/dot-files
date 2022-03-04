#!/usr/bin/env bash

# Change prefix {{{

tmux unbind-key C-b
tmux set-option -g prefix C-Space

# }}}
# New Window {{{

tmux bind-key c new-window

#}}}
# New Pane {{{

# Open a new pane with current pane's path
tmux bind-key h split-window -hb -c "#{pane_current_path}"
tmux bind-key l split-window -h -c "#{pane_current_path}"
tmux bind-key j split-window -v -c "#{pane_current_path}"
tmux bind-key k split-window -vb -c "#{pane_current_path}"

# }}}
# Pane resize {{{

tmux bind-key H resize-pane -L 5
tmux bind-key J resize-pane -D 5
tmux bind-key K resize-pane -U 5
tmux bind-key L resize-pane -R 5

#}}}
# Copy mode {{{

# Prefix + Esc to enter copy mode
tmux bind-key Escape copy-mode

# Visual selection in copy mode
tmux bind-key -T copy-mode-vi 'v' send -X begin-selection

# Paste buffer
tmux bind-key C-p paste-buffer

#}}}
# Save history to file {{{

tmux bind-key M command-prompt -p 'save history to filename:' -I '/tmp/tmux.history' 'capture-pane -S -32768 ; save-buffer %1 ; delete-buffer'

#}}}

# vim:filetype=tmux:foldmethod=marker
