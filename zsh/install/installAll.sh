#!/bin/bash

platform=`uname`
if [ $platform = 'Linux' ]; then
    installer='sudo apt install -y'
elif [ $platform = 'Darwin' ]; then
    installer='brew install'
fi

# autojump
$installer autojump

# colordiff
$install colordiff

# tmux
./installTmux.sh

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# zsh-augosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# GNU coreutils dircolors
curl https://raw.githubusercontent.com/coreutils/coreutils/master/src/dircolors.hin -o $HOME/.dircolors

# install coreutils on macOS
if [[ $platform = 'Darwin' ]]; then
    $installer coreutils
fi

# install powerline
pip install powerline-status

# fix unicode ⚡ in iTerm2
# Toggle `Use Unicode version 9 widths`
