# general setting
# echo "Loading general setting"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf-extras/fzf-extras.sh ] && source ~/.fzf-extras/fzf-extras.sh
[ -f ~/.fzf-extras/fzf-extras.zsh ] && source ~/.fzf-extras/fzf-extras.zsh
if [[ `uname` = 'Linux' ]]; then
    export OPENER=xdg-open
elif [[ `uname` = 'Dawin' ]]; then
    export OPENER=open
fi
alias fd="zd"
# unset e for editing frequent files becuase fasd is not available yet
unset -f e

# capslock tap as Escape key
if [[ `uname` = 'Linux' ]]; then
    xcape -e 'Caps_Lock=Escape'
# elif [[ `uname` = 'Dawin' ]]; then
#     echo "macOS: capslock tap as ESC key"
fi

# deduplicate history
# manually: sort -t ";" -k 2 -u ~/.zsh_history | sort -o ~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
