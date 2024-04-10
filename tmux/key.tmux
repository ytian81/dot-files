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

tmux set-option -g repeat-time 1000
tmux bind-key -r C-h resize-pane -L 5
tmux bind-key -r C-j resize-pane -D 5
tmux bind-key -r C-k resize-pane -U 5
tmux bind-key -r C-l resize-pane -R 5

# }}}
# Pane movement {{{

# move pane to the far right/left/bottom/top
tmux bind-key H 'split-window -fhb ; swap-pane -t ! ; kill-pane -t !'
tmux bind-key L 'split-window -fh  ; swap-pane -t ! ; kill-pane -t !'
tmux bind-key J 'split-window -fv  ; swap-pane -t ! ; kill-pane -t !'
tmux bind-key K 'split-window -fvb ; swap-pane -t ! ; kill-pane -t !'

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

tmux bind-key M command-prompt -p 'save history to filename:' -I '/tmp/tmux.history' 'capture-pane -J -S- -E-; save-buffer %1 ; delete-buffer'

#}}}
# Float window for top {{{

tmux bind-key b run-shell "tmux popup -w80% -h60% -E btop > /dev/null 2>&1"

#}}}

# vim:filetype=tmux:foldmethod=marker
