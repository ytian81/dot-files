# alias setting
# echo "Loading alias setting"

alias c='clear'
alias cat='bat'
alias x='exit'
alias diff='delta --side-by-side'
alias gdc='gd --cached'
alias gstf='gst | fpp'
alias xclip='xclip -selection c'
alias vi='vim -u NONE'
[[ -n "$(command -v nvim)" ]] && alias vim="nvim"
if [ `uname` = 'Linux' ]; then
    alias o='xdg-open'
elif [ `uname` = 'Darwin' ]; then
    alias o='open'
fi
