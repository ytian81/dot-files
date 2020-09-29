# alias setting
# echo "Loading alias setting"

alias c='clear'
alias cat='bat'
alias x='exit'
alias diff='colordiff'
alias gdmd='git difftool --tool=meld --dir-diff'
alias gdmdc='git difftool --tool=meld --dir-diff --cached'
alias gdvd='git difftool --tool=vimdiff'
alias gdvdc='git difftool --tool=vimdiff --cached'
alias gstf='gst | fpp'
alias xclip='xclip -selection c'
[[ -n "$(command -v nvim)" ]] && alias vim="nvim"
if [ `uname` = 'Linux' ]; then
    alias o='xdg-open'
elif [ `uname` = 'Darwin' ]; then
    alias o='open'
fi
