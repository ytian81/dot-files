#!/usr/bin/env zsh
# =============================================================================
# fzf-git-views.sh: TUI View Pickers for Git.
# =============================================================================
#
# This script defines interactive FZF pickers for Git.
# It can be sourced in your shell to define the functions, or executed directly
# as a script to run a specific picker.
#
# Usage (Sourced):  source /path/to/fzf-git-views.sh
# Usage (Executed): /path/to/fzf-git-views.sh <command> [args]
#
# =============================================================================

source $DOT_FILES_PATH/scripts/fzf-viewer.sh

# git_fzf_diff: Interactive status/diff viewer
git_fzf_diff() {
    local input="git status -su"
    local preview="git diff --color=always $* -- \"{2..}\""
    local opts="-m --prompt='git diff> ' --bind='enter:become(nvim {2..})' --bind='ctrl-v:become(nvim {2..})'"
    run_fzf "$@"
}

# git_fzf_show: Interactive commit log viewer
git_fzf_show() {
    local input="git log --color=always --oneline"
    local preview="git show --color=always \"{1}\""
    local opts="--prompt='git log> ' --bind='enter:execute(git show --color=always {1} | less -R)'"
    run_fzf "$@"
}

# git_fzf_add: Interactive git add selector (multi-select)
git_fzf_add() {
    local changed untracked unmerged extract preview

    # Helper to extract clean file path from git status line
    extract="sed 's/^.*]  //' | sed 's/.* -> //' | sed -e 's/^\"//' -e 's/\"$//'"

    # Preview logic: if untracked (starts with [??]), diff against /dev/null
    preview="
        file=\$(echo {} | $extract)
        if (echo {} | grep -F '[??]') &>/dev/null; then
            git diff --color=always --no-index -- /dev/null \"\$file\" | delta | sed '2 s/added:/untracked:/'
        else
            git diff --color=always -- \"\$file\" | delta
        fi"

    # Resolve git status color codes
    changed=$(git config --get-color color.status.changed red)
    unmerged=$(git config --get-color color.status.unmerged red)
    untracked=$(git config --get-color color.status.untracked red)

    local input="git -c color.status=always status -su |
        grep -F -e \"$changed\" -e \"$unmerged\" -e \"$untracked\" |
        sed -E 's/^(..[^[:space:]]*)[[:space:]]+(.*)$/[\1]  \2/'"

    local opts="-m --prompt='git add> '"

    # Run and capture selections (Enter prints selections and exits)
    local selections
    selections=$(run_fzf "$@" | eval "$extract")

    if [[ -n "$selections" ]]; then
        echo "$selections" | tr '\n' '\0' | xargs -0 git add
        git status -su
    fi
}

# git_fzf_checkout_file: Interactive git checkout/restore file selector
git_fzf_checkout_file() {
    local input="git ls-files --modified"
    local preview="git diff --color=always -- \"{}\""
    local opts="-m --prompt='git checkout file> '"

    local selections
    selections=$(run_fzf "$@")
    if [[ -n "$selections" ]]; then
        echo "$selections" | tr '\n' '\0' | xargs -0 git checkout --
        git status -su
    fi
}

# git_fzf_checkout_branch: Interactive git branch switcher
git_fzf_checkout_branch() {
    local input="git branch --color=always --all"
    # Preview log of highlighted branch (strips leading * or space)
    local preview="git log --color=always --oneline --graph \$(echo {} | sed 's/^[ *]*//')"
    # Become git switch (strips remotes/origin/ prefix if switching to remote tracking)
    local enter="become(sh -c 'branch=\$(echo {} | sed \"s/^[ *]*//\" | sed \"s|^remotes/||\"); git switch \"\$branch\"')"
    local opts="--prompt='git checkout branch> '"

    run_fzf "$@"
}

# git_fzf_stash_show: Interactive git stash manager
git_fzf_stash_show() {
    local input="git stash list"
    local preview="git stash show --color=always --ext-diff {1} | delta"
    local opts="
        --prompt='git stash> '
        --bind='enter:execute(git stash show -p {1} | delta | less -R)'
        --bind='ctrl-p:become(git stash pop {1})'
        --bind='ctrl-d:become(git stash drop {1})'
        --bind='ctrl-a:become(git stash apply {1})'
        --header=':: Press CTRL-P to pop, CTRL-D to drop, CTRL-A to apply'
    "
    run_fzf "$@"
}

# git_fzf_reset_head: Interactive git reset (unstage) selector
git_fzf_reset_head() {
    local input="git diff --staged --name-only"
    local preview="git diff --staged --color=always -- \"{}\""
    local opts="-m --prompt='git unstage> '"

    local selections
    selections=$(run_fzf "$@")
    if [[ -n "$selections" ]]; then
        echo "$selections" | tr '\n' '\0' | xargs -0 git reset -q HEAD --
        git status -su
    fi
}

# git_fzf_clean: Interactive git clean (delete untracked) selector
git_fzf_clean() {
    local input="git clean -dffn | sed 's/^Would remove //'"
    local opts="-m --prompt='git clean> '"

    local selections
    selections=$(run_fzf "$@")
    if [[ -n "$selections" ]]; then
        echo "$selections" | tr '\n' '\0' | xargs -0 git clean -xdff --
        git status -su
    fi
}
