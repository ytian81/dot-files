# alias setting
# echo "Loading alias setting"

alias x='exit'
alias diff='colordiff'
alias gdmd='git difftool --tool=meld --dir-diff'
alias gdmdc='git difftool --tool=meld --dir-diff --cached'
alias gdvd='git difftool --tool=vimdiff'
alias gdvdc='git difftool --tool=vimdiff --cached'
if [ `uname` = 'Linux' ]; then
    alias o='xdg-open'
elif [ `uname` = 'Darwin' ]; then
    alias o='open'
    alias vim='mvim -v'
fi
