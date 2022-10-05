#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# if brew not installed, install homebrew first

# for loop, check if installed

# install cli-software
brew install autojump
brew install bat
brew install colordiff
brew install coreutils # for gdircolors
brew install fasd
brew install git
brew install git-delta
brew install neovim
brew install node
brew install svn
brew install thefuck
brew install tldr
brew install tree
brew install tmux
brew install universal-ctags

# install gui-software
brew install iterm2
brew install karabiner-elements
brew install rectangle
brew install visual-studio-code
brew tap homebrew/cask-drivers
brew install --cask logitech-options
