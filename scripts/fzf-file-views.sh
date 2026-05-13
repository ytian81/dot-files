#!/usr/bin/env zsh
# =============================================================================
# fzf-file-views.sh: TUI View Pickers for File Navigation & History.
# =============================================================================
#
# This script defines interactive FZF pickers for files and history.
# It is meant to be sourced in your shell configuration (e.g., ~/.zshrc).
#
# Usage: source /path/to/fzf-file-views.sh
#
# =============================================================================

source $DOT_FILES_PATH/scripts/fzf-viewer.sh

# file_fzf_finder: Fuzzy File Opener (multi-select vertical/horizontal splits)
# Example: file_fzf_finder [query]
file_fzf_finder() {
    local input="${FZF_DEFAULT_COMMAND:-find . -type f}"
    local preview="bat --style=numbers --color=always --line-range :500 {}"

    # Native FZF become:
    # - enter: Opens selected files in vertical splits (nvim -O)
    # - ctrl-v: Opens selected files in horizontal splits (nvim -o)
    local opts="-m -0 --select-1 --ghost='fuzzfy finder' --bind='enter:become(nvim -O {+})' --bind='ctrl-v:become(nvim -o {+})'"

    # If query argument ($1) is passed, feed it to fzf
    [[ -n "$1" ]] && opts+=" --query=\"$1\""

    run_fzf
}

zle -N file_fzf_finder
bindkey '^f' file_fzf_finder

# file_fzf_mru: Neovim Oldfiles History Picker (hybrid absolute/relative paths)
file_fzf_mru() {
    # Headless nvim dump of v:oldfiles, filtered for readability.
    # We use fnamemodify(..., ":.") which returns:
    #   - Relative path if inside PWD (e.g. src/main.py)
    #   - Full absolute path if outside PWD (e.g. /etc/hosts)
    # This completely eliminates the need for '~' tilde expansion!
    local input="nvim --headless --noplugin -u NONE \
        -c 'set shada+=r/tmp' \
        -c 'rshada' \
        -c 'let list = filter(copy(v:oldfiles), \"filereadable(expand(v:val))\")' \
        -c 'let hybrid_list = map(list, \"fnamemodify(v:val, \\\":.\\\")\")' \
        -c 'echo join(hybrid_list, \"\\n\")' \
        -c 'qa' 2>&1 | tr -d '\r'"

    local preview="bat --style=numbers --color=always --line-range :500 {}"

    # Native FZF become:
    # - enter: Opens selected history files in vertical splits (nvim -O)
    # - ctrl-v: Opens selected history files in horizontal splits (nvim -o)
    local opts="-m -0 --select-1 --ghost='mru finder' --bind='enter:become(nvim -O {+})' --bind='ctrl-v:become(nvim -o {+})'"

    run_fzf
}

export FZF_CTRL_T_COMMAND=
zle -N file_fzf_mru
bindkey '^t' file_fzf_mru
