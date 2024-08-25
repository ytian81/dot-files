#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

# if homebrew not detected, install homebrew first

# install source code pro
brew install font-source-code-pro

# install nerdfonts
# # install fonts via directly downloading
# # https://github.com/romkatv/powerlevel10k#how-was-the-recommended-font-created
# function install_fonts_via_directly_downloading() {
#   mkdir -p -- ~/Library/Fonts
#   local -r font_base_url='https://github.com/romkatv/powerlevel10k-media/raw/master'
#   local style
#   for style in Regular Bold Italic 'Bold Italic'; do
#     local file="MesloLGS NF ${style}.ttf"
#     curl -fsSL -o ~/Library/Fonts/$file.tmp "$font_base_url/${file// /%20}"
#     mv -f -- ~/Library/Fonts/$file{.tmp,} || quit -c
#   done
# }
# install_fonts_via_directly_downloading
brew install font-meslo-lg-nerd-font
