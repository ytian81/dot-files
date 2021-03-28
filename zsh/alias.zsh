# alias setting
# echo "Loading alias setting"

alias c='clear'
alias cat='bat'
alias x='exit'
alias diff='colordiff'
alias gd='git -c delta.side-by-side=true diff'
alias gdc='git -c delta.side-by-side=true diff --cached'
alias gstf='gst | fpp'
alias xclip='xclip -selection c'
[[ -n "$(command -v nvim)" ]] && alias vim="nvim"
if [ `uname` = 'Linux' ]; then
    alias o='xdg-open'
elif [ `uname` = 'Darwin' ]; then
    alias o='open'
fi
