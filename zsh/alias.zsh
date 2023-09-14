# alias setting
# echo "Loading alias setting"

alias c='clear'
alias cat='bat'
alias x='exit'
alias :q='exit'
alias :wq='exit'
alias diff='delta --side-by-side'
alias gdc='gd --cached'
alias gcne='git commit --no-edit'
alias gstf='gst | fpp'
alias vi='vim -u NONE'
alias gcn='forgit::clean'
[[ -n "$(command -v nvim)" ]] && alias vim="nvim"
if [ `uname` = 'Linux' ]; then
    alias o='xdg-open'
elif [ `uname` = 'Darwin' ]; then
    alias o='open'
fi
