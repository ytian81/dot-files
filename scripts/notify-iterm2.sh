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

# otherwise, we need to wire the content to the right tty ourselves
if [ -n "${TMUX-}" ]; then
  # wrap tmux pass through escape sequence
  esc="\ePtmux;\e$esc\e\\"
  # set to tmux client tty
  target_tty=$(tmux display-message -p "#{client_tty}")
else
  # set to normal tty if not in tmux
  target_tty=$(tty)
fi

# set to SSH_TTY if in a SSH session
target_tty="${SSH_TTY:-$target_tty}"

printf "$esc" > "$target_tty"
