#!/usr/bin/env bash
# =============================================================================
# fzf-viewer.sh: A generic, dynamically-scoped TUI engine for fzf viewers.
# =============================================================================
#
# This script provides a robust, minimal engine `run_fzf` that dynamically
# configures fzf by inheriting local variables from calling wrapper functions.
# It cleanly decouples domain logic (data gathering, previews, keybind actions)
# from TUI presentation boilerplate.
#
# Architectural Benefits:
#   - 100% Portable across Bash and Zsh (can be sourced in either).
#   - Zero Global Namespace Pollution (utilizes dynamic scoping via `local`).
#   - Action Agnostic (callers fully define bindings inside `opts`).
#   - Theme Preserving (respects global FZF_DEFAULT_OPTS environment styling).
#
# Usage:
#   1. Source this script in your shell configuration (e.g., ~/.zshrc or fzf-views.sh):
#      source /path/to/fzf-viewer.sh
#
#   2. Define an ergonomic wrapper function declaring local config variables:
#      git_diff() {
#          local input="git status -su"
#          local preview="git diff --color=always -- \"{2..}\""
#          local opts="-m --bind='enter:become(nvim \"{2..}\")' --bind='ctrl-v:become(nvim \"{2..}\")'"
#
#          run_fzf "$@"
#      }
#
#   3. Execute your function directly from the CLI (trailing args are passed to input):
#      git_diff my_file.cc
#
# =============================================================================

# Source once
[[ -n "${_FZF_VIEWER_SH_INCLUDED}" ]] && return 0
_FZF_VIEWER_SH_INCLUDED=1

run_fzf() {
    # Ensure required input command variable is defined in caller scope
    if [[ -z "$input" ]]; then
        echo "run_fzf: Error - local variable 'input' is not defined in calling function." >&2
        return 1
    fi

    # Build FZF configuration.
    # 1. Start with caller's global FZF_DEFAULT_OPTS environment variable (respects theme styling).
    # 2. Inject base TUI engine behavior (ansi, zero-match exit, preview toggles).
    #    CRITICAL FIX: If FZF_DEFAULT_OPTS contains multi-line \n newlines (common in zshrc configs),
    #    we sanitize them into spaces so eval doesn't treat them as multi-line command separators!
    local fzf_opts="$FZF_DEFAULT_OPTS"

    # 3. Conditionally append preview window if defined.
    # 4. View-specific $opts handle all custom bindings (enter, ctrl-v, etc.) and override defaults.
    [[ -n "$preview" ]] && fzf_opts+=" --preview=\"$preview\""
    [[ -n "$header" ]]  && fzf_opts+=" --header=\"${FZF_HEADER_OPTS:+$FZF_HEADER_OPTS, }$header\""
    [[ -n "$opts" ]]    && fzf_opts+=" $opts"

    #    CRITICAL FIX: If fzf opts contains multi-line \n newlines (common in zshrc configs),
    #    we sanitize them into spaces so eval doesn't treat them as multi-line command separators!
    fzf_opts="${fzf_opts//$'\n'/ }"

    # Execute fzf
    # - Trailing arguments ($@) are interpolated into the input command.
    # - We pass $fzf_opts as direct CLI arguments via eval.
    #   CRITICAL ARCHITECTURAL BENEFIT: By passing options via CLI instead of overriding FZF_DEFAULT_OPTS,
    #   any child process spawned by fzf (become/execute like Neovim) inherits the PRISTINE, ORIGINAL
    #   FZF_DEFAULT_OPTS from the parent shell! This ensures fzf plugins inside Neovim work flawlessly!
    eval "$input" "$@" | eval "fzf $fzf_opts"
}
