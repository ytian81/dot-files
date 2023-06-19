#!/bin/bash

set -eu

if (( $# == 0 )) ; then
    # if no argument, read from standard input from pipe
    buf=$(cat "$@")
else
    # otherwise read from all arguments
    buf=$@
fi

# wrap notificatin esccape sequence
esc="\e]9;$buf\a"

# for an interactive shell, we can directly do `printf "$esc"` to pipe thing content to right tty
# printf "$esc"

# otherwise, we need to wire the content to the right tty ourselves
if [ -n "${TMUX-}" ]; then
  # wrap tmux pass through escape sequence
  esc="\ePtmux;\e$esc\e\\"
  # set to tmux pane tty
  target_tty=$(tmux list-panes -F "#{pane_active} #{pane_tty}" | awk '$1=="1" { print $2 }')
else
  # set to normal tty
  target_tty=$(tty)
fi

# set to SSH_TTY if in a SSH session
target_tty="${SSH_TTY:-$target_tty}"

printf "$esc" > "$target_tty"
