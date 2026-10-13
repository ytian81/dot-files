#!/usr/bin/env bash
# Wrapper to run btop inside a tmux popup with standalone Esc mapped to quit.
#
# Why this exists:
# - In tmux, `display-popup` forwards all keystrokes directly to the popup's PTY
#   while the command is running (its built-in Esc dismissal only applies after
#   a command exits when `-E` is not used).
# - In btop, keybindings are hardcoded and pressing standalone `Esc` opens the
#   Options/Help/Quit menu instead of quitting (unlike other tmux popups such as
#   fzf where `Esc` dismisses the popup).
#
# How it works:
# - `btop` requires stdin to be a real TTY (`isatty(0)`), so we wrap `btop` in
#   `script -q -c ... /dev/null` to allocate a child PTY with the popup's
#   current terminal dimensions (`stty rows/cols`).
# - We read raw bytes from the popup TTY (`read -rsn1 -d ''`). When `\e` (0x1b)
#   arrives, we wait 20ms (`-t 0.02`) for a follow-up byte:
#   - Multi-byte escape sequences (arrow keys `\e[A`, mouse events `\e[<...`,
#     Alt+key) have immediate follow-up bytes and pass through untouched.
#   - A standalone `Esc` (or double-`Esc`) has no follow-up byte and is
#     translated to `\x03` (Ctrl-C), which tells `btop` to cleanly save state,
#     restore terminal modes, and exit (closing `tmux display-popup -E`).

trap 'exit 0' TERM

read -r rows cols < <(stty size)
stty raw -echo

{
    while IFS= read -rsn1 -d '' k; do
        if [[ $k == $'\e' ]]; then
            IFS= read -rsn1 -d '' -t 0.02 k2 || { printf '\x03'; continue; }
            [[ $k2 == $'\e' ]] && { printf '\x03'; continue; }
            printf '%s%s' "$k" "$k2"
        else
            printf '%s' "$k"
        fi
    done
} > >(script -q -c "stty rows $rows cols $cols; exec btop -u 500" /dev/null; kill $$ 2>/dev/null)

wait
