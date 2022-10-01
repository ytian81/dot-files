#!/usr/bin/env zsh

# set -euo pipefail
# IFS=$'\n\t'

# install zsh
function install_oh_my_zsh() {
  sh -c "RUNZSH=no; KEEP_ZSHRC=yes; $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function install_zsh_themes_and_plugins() {
  git clone --depth=1 https://github.com/romkatv/powerlevel10k ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  git clone --depth=1 https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
  git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use
  git clone --depth=1 https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoupdate
  git clone --depth=1 https://github.com/wfxr/forgit ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit
  git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
  git clone --depth=1 https://github.com/ytian81/fzf-extras ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-extras
}
function install_zsh() {
  install_oh_my_zsh
  install_zsh_themes_and_plugins
}
# install_zsh

# install dot files
function download_dot_files() {
  git clone --depth=1 git@github.com:ytian81/dot-files.git ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}
}

function link_config_files() {
  # zsh
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/.zshrc $HOME/.zshrc

  # nvim
  mkdir -p $HOME/.config/nvim
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/.vimrc $HOME/.vimrc
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/vim/coc-settings.json $HOME/.config/nvim/coc-settings.json
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/vim/init.vim $HOME/.config/nvim/init.vim

  # tmux
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/.tmux.conf $HOME/.tmux.conf

  # dircolors
  curl -fsSL https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark -o $HOME/.dircolors

  # ctags
  ln -sf ${DOT_FILES_PATH:-$HOME/Documents/Configurations/dot-files}/.ctags.d $HOME/.ctags.d

  # bazel zsh auto completion
  mkdir -p $HOME/.zsh/completion
  mkdir -p $HOME/.zsh/cache
  wget https://raw.githubusercontent.com/bazelbuild/bazel/master/scripts/zsh_completion/_bazel --output-document $HOME/.zsh/completion/_bazel
  rm -f $HOME/.zcompdump; compinit

  # bat-syntax
  mkdir -p $HOME/.config/bat/syntaxes
  git clone https://github.com/facelessuser/sublime-languages $HOME/.config/bat/syntaxes
  bat cache --build
}
# link_config_files
