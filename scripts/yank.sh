#!/bin/bash

set -eu

is_app_installed() {
  type "$1" &>/dev/null
}

# get data either form stdin or from file
if (( $# == 0 )) ; then
  # if no argument, read from standard input from pipe
  buf=$(cat "$@")
else
  # otherwise read from all arguments
  buf=$@
fi

# Resolve copy backend: pbcopy (OSX), reattach-to-user-namespace (OSX), xclip/xsel (Linux)
copy_backend=""
if is_app_installed pbcopy; then
  copy_backend="pbcopy"
elif is_app_installed reattach-to-user-namespace; then
  copy_backend="reattach-to-user-namespace pbcopy"
elif [ -n "${DISPLAY-}" ] && is_app_installed xsel; then
  copy_backend="xsel -i --clipboard"
elif [ -n "${DISPLAY-}" ] && is_app_installed xclip; then
  copy_backend="xclip -i -f -selection primary | xclip -i -selection clipboard"
fi

# if copy backend is resolved, copy and exit
if [ -n "$copy_backend" ]; then
  printf "$buf" | eval "$copy_backend"
  exit;
fi

# Copy via OSC 52 ANSI escape sequence to controlling terminal
buflen=$( printf %s "$buf" | wc -c )

# https://sunaku.github.io/tmux-yank-osc52.html
# The maximum length of an OSC 52 escape sequence is 100_000 bytes, of which
# 7 bytes are occupied by a "\033]52;c;" header, 1 byte by a "\a" footer, and
# 99_992 bytes by the base64-encoded result of 74_994 bytes of copyable text
maxlen=74994

# warn if exceeds maxlen
if [ "$buflen" -gt "$maxlen" ]; then
  printf "input is %d bytes too long" "$(( buflen - maxlen ))" >&2
fi

# build up OSC 52 ANSI escape sequence
esc="\033]52;c;$( printf %s "$buf" | head -c $maxlen | base64 | tr -d '\r\n' )\a"

if [ -n "${TMUX-}" ]; then
  # if tmux is greater than 3.2 than we can directly use tmux load buffer -w flag to
  # access system clipboard
  tmux_version=${TMUX_VERSION-:$(tmux -V | sed -En 's/^tmux[^0-9]*([.0-9]+).*/\1/p')}
  if [[ $(awk '{print ($1 >= 3.2)}' <<< "$tmux_version" 2> /dev/null || bc -l <<< "$tmux_version >= 3.2") = 1 ]]; then
    printf "$buf" | tmux load-buffer -w -
    exit;
  fi

  # wrap tmux pass through escape sequence
  esc="\033Ptmux;\033$esc\033\\"
  # set to tmux client tty
  target_tty=$(tmux display-message -p "#{client_tty}")
else
  # set to normal tty if not in tmux
  target_tty=$(tty)
fi

# set to SSH_TTY if in a SSH session
target_tty="${SSH_TTY:-$target_tty}"

printf "$esc" > "$target_tty"
