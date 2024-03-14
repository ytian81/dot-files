#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# if brew not installed, install homebrew first

# for loop, check if installed

# install cli-software
brew install autojump
brew install bat
brew install coreutils # for gdircolors
brew install fasd
brew install git
brew install ripgrep
brew install git-delta
brew install lf
brew install neovim
brew install node
brew install thefuck
brew install tldr
brew install tree
brew install tmux
brew install universal-ctags
brew install superbrothers/opener/opener
brew services start opener

# install gui-software
brew install 1password
brew install google-chrome
brew install iterm2
brew install karabiner-elements
brew install logi-options-plus
brew install raycast
brew install visual-studio-code
