# color setting
echo "Loading color setting"

export TERM='xterm-256color'

# draw line between two commands
setopt promptsubst
PS1=$'${(r:$COLUMNS::\u2504:)}'$PS1

# GNU coreutils ls color
if [ `uname` = 'Linux' ]; then
    eval `dircolors  ~/.dircolors`
elif [ `uname` = 'Darwin' ]; then
    # GNU dircolors is renamed gdircolors on macOS
    eval `gdircolors  ~/.dircolors`
fi

# tmux powerline status branch
if [[ -z $powerline_dir ]]; then
    export powerline_dir=$(pip show powerline-status | grep Location | awk {'print $2'})/powerline/
fi
source $powerline_dir"/bindings/zsh/powerline.zsh"
