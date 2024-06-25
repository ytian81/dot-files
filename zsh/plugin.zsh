# vi-mode
# 100ms for key sequences for faster mode transition in zsh vi-mode
KEYTIMEOUT=10 # in hundredth of a second

VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_INSERT=5

# Edit line in vim with ctrl-o:
autoload edit-command-line; zle -N edit-command-line
bindkey '^o' edit-command-line
bindkey -M vicmd '^o' edit-command-line

# https://unix.stackexchange.com/questions/373302/is-it-possible-to-make-vi-mode-in-zsh-not-interfere-with-escape-sequences
# '^[b' and '^[f' are built-in escape sequence to move cursor by word. However, when vi mode is
# enabled in zsh, then the escape '^[' will be captured by zsh to enter normal mode regardless of
# KEYTIMEOUT value. So it needs to be explicitly defined as a key map in the vi insert mode to avoid
# any interference.
bindkey -M viins '^[b' vi-backward-word # or backward-word
bindkey -M viins '^[f' vi-forward-word # or forward-word

# ^U is mapped to vi-kill-line when vi-mode is enabled in zsh. It only clears text newly inserted
# after entering the vi-insert mode. Remapping it to backward-kill-line to clear all text between
# cursor and the beginning of the line
bindkey '^U' backward-kill-line

# forgit Use ctrl-v to open commit in vim
export FORGIT_LOG_FZF_OPTS="--bind=\"ctrl-v:become(echo {} |grep -Eo '[a-f0-9]+' | head -1 | xargs printf -- 'Gedit %s' | xargs -0 nvim -c )\" "
export FORGIT_GLO_FORMAT=$FZF_GIT_COMMITS_LOG_FORMAT
export FORGIT_DIFF_FZF_OPTS="--bind=\"ctrl-v:become( export FZF_DEFAULT_OPTS=\$FZF_DEFAULT_OPTS_RESET && $EDITOR {2} )\" "
export FORGIT_COPY_CMD=$YANK_SCRIPT

# fzf-tab config for fzf height
export FZF_TMUX_HEIGHT='80%'
