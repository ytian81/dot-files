#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# if brew not installed, install homebrew first

# for loop, check if installed

# install cli-software
brew install autojump
brew install git
brew install neovim
brew install svn
brew install thefuck
brew install tmux

# install gui-software
brew install alt-tab
brew install iterm2
brew install karabiner-elements
brew install rectangle
brew install visual-studio-code
brew tap homebrew/cask-drivers
brew install --cask logitech-options
