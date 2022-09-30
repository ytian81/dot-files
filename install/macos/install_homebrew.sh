#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

sudo xcode-select --install

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> $HOME/.zprofile\
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile\
eval "$(/opt/homebrew/bin/brew shellenv)"
