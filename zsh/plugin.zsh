# vi-mode
# 10ms for key sequences
KEYTIMEOUT=1
# Use vim keys in tab complete menu:
zstyle ':completion:*' menu select
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^o' edit-command-line

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
