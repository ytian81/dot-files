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

# forgit Use ctrl-v to open commit in vim
export FORGIT_LOG_FZF_OPTS="--bind=\"ctrl-v:execute(echo {} |grep -Eo '[a-f0-9]+' | head -1 | xargs printf -- 'Gedit %s' | xargs -0 nvim -c )\" "
export FORGIT_GLO_FORMAT="%C(auto)%h%d %s %C(black)%C(bold)%aN %cr%Creset"
export FORGIT_DIFF_FZF_OPTS="--bind=\"ctrl-v:execute( export FZF_DEFAULT_OPTS=\$FZF_DEFAULT_OPTS_RESET && $EDITOR {2} )\" "
export FORGIT_COPY_CMD=$YANK_SCRIPT

# fzf-tab config for fzf height
export FZF_TMUX_HEIGHT='80%'
