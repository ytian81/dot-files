# general setting
# echo "Loading general setting"

# # set PATH so it includes user's private bin if it exists
# if [ -d "$HOME/.local/bin" ] ; then
#     PATH="$HOME/.local/bin:$PATH"
# fi

# source fzf if not already
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export YANK_SCRIPT="$DOT_FILES_PATH/scripts/yank.sh"
alias yank=$YANK_SCRIPT
export NOTIFY_SCRIPT="$DOT_FILES_PATH/scripts/notify-iterm2.sh"
alias notify=$NOTIFY_SCRIPT
export LOCAL_OPEN_SCRIPT="$DOT_FILES_PATH/scripts/local-open.sh"
alias local-open=$LOCAL_OPEN_SCRIPT

# check if in ssh session, if so, use local-open
if [[ -n $SSH_CONNECTION ]]; then
    export BROWSER=$LOCAL_OPEN_SCRIPT
fi

# fzf
# Open in tmux popup if on tmux, otherwise use --height mode
export FZF_DISPLAY_OPTS="--height 80% --tmux center,80%,60%"
export FZF_DEFAULT_OPTS="
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54,border:#928374
  --layout=reverse
  --border
  --no-separator
  --info=inline-right
  --bind='ctrl-b:preview-half-page-up,ctrl-f:preview-half-page-down'
  --bind='ctrl-u:half-page-up,ctrl-d:half-page-down'
  --bind='ctrl-/:change-preview-window(down,60%|hidden|right,60%)'
  --bind='ctrl-y:execute-silent(print {} | $YANK_SCRIPT)'
  --header=\"$(printf ':: Press \033[38;5;208mCTRL-Y\033[0m to yank, \033[38;5;208mCTRL-/\033[0m to toggle preview')\"
  --preview-window=right,60%
  $FZF_DISPLAY_OPTS
"
export FZF_DEFAULT_OPTS_RESET=$FZF_DEFAULT_OPTS
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --ignore-vcs'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:+$FZF_CTRL_R_OPTS }--preview 'echo {}' --preview-window down:5:wrap"
export FZF_GIT_COMMITS_LOG_FORMAT="%C(auto)%h%d %s %C(black)%C(bold)%aN %cr%Creset"

if [[ `uname` = 'Linux' ]]; then
    export OPENER=xdg-open
elif [[ `uname` = 'Dawin' ]]; then
    export OPENER=open
fi

# fasd
eval "$(fasd --init auto)"
# fzf-extras overloads zz
unalias zz
# prefer oh-mh-zsh's d behavior
unalias d

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
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with ls when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# bazel auto complete
fpath[1,0]=~/.zsh/completion/
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# bat configuation
export BAT_THEME='gruvbox-dark'
export BAT_STYLE='numbers,changes,rule'

# fix ssh-agent issue
function fix_ssh_auth() {
    ln -sf `ls /tmp/ssh-*/agent*` ~/.ssh/ssh_auth_sock
}
