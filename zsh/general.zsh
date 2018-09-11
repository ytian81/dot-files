# general setting
# echo "Loading general setting"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf-extras/fzf-extras.zsh ] && source ~/.fzf-extras/fzf-extras.zsh

# capslock tap as Escape key
if [[ `uname` = 'Linux' ]]; then
    xcape -e 'Control_L=Escape'
# elif [[ `uname` = 'Dawin' ]]; then
#     echo "macOS: capslock tap as ESC key"
fi
