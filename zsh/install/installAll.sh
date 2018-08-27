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

# install coreutils on macOS
if [[ $platform = 'Darwin' ]]; then
    $installer coreutils
fi

# fix unicode ⚡ in iTerm2
# Toggle `Use Unicode version 9 widths`
