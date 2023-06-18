#!/bin/bash

set -eu

buf=$(cat "$@")

# wrap notificatin esccape sequence
esc="\e]9;$buf\a"

# for an interactive shell, we can directly do `printf "$esc"` to pipe thing content to right tty
# printf "$esc"

# otherwise, we need to wire the content to the right tty ourselves
esc="\ePtmux;\e$esc\e\\"
pane_active_tty=$(tmux list-panes -F "#{pane_active} #{pane_tty}" | awk '$1=="1" { print $2 }')
target_tty="${SSH_TTY:-$pane_active_tty}"

printf "$esc" > "$target_tty"
