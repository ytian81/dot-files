# general setting
# echo "Loading general setting"

# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/.local/bin" ] ; then
#     PATH="$HOME/.local/bin:$PATH"
# fi

# fzf
[ -f ~/.fzf-extras/fzf-extras.sh ] && source ~/.fzf-extras/fzf-extras.sh
[ -f ~/.fzf-extras/fzf-extras.zsh ] && source ~/.fzf-extras/fzf-extras.zsh
export FZF_DEFAULT_OPTS='
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
  --layout=reverse
  --height 80%
  --border
  --keep-right
  --bind ctrl-b:preview-half-page-up,ctrl-f:preview-half-page-down,ctrl-/:toggle-preview
  --preview-window=right,60%
'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if [[ `uname` = 'Linux' ]]; then
    export OPENER=xdg-open
elif [[ `uname` = 'Dawin' ]]; then
    export OPENER=open
fi
alias fd="zd"
# unset e for editing frequent files becuase fasd is not available yet
unset -f e

# deduplicate history
# manually: sort -t ";" -k 2 -u ~/.zsh_history | sort -o ~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS

# use nvim if it exists, otherwise use vim
if [ -n "$(command -v nvim)" ]; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with ls when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
