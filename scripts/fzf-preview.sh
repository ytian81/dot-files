#!/usr/bin/env bash
# =============================================================================
# fzf-preview.sh: File & Image Previewer for FZF (Shell + Neovim).
# =============================================================================
#
# Renders syntax-highlighted text via `bat` and full-resolution inline images
# via `chafa`'s Kitty Unicode placeholder mode (with tmux passthrough).
# Supports `FILE`, `FILE:LINE`, and `FILE:LINE:COL` arguments.
# =============================================================================

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 FILE[:LINENO][:IGNORED]" >&2
  exit 1
fi

file=$1
center=0

# Expand leading ~/
file="${file/#\~\//$HOME/}"

# Strip trailing :LINENO[:COL] if the raw argument is not directly readable
if [[ ! -r $file ]]; then
  if [[ $file =~ ^(.+):([0-9]+)\ *$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
    file=${BASH_REMATCH[1]}
    center=${BASH_REMATCH[2]}
  elif [[ $file =~ ^(.+):([0-9]+):[0-9]+\ *$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
    file=${BASH_REMATCH[1]}
    center=${BASH_REMATCH[2]}
  fi
fi

if [[ -d $file ]]; then
  ls -la --color=always "$file"
  exit
fi

if [[ ! -r $file ]]; then
  echo "File not found: $file"
  exit
fi

mime=$(file --brief --dereference --mime -- "$file")

if [[ $mime =~ ^image/ ]] && command -v chafa >/dev/null 2>&1; then
  dim="${FZF_PREVIEW_COLUMNS:-80}x${FZF_PREVIEW_LINES:-40}"
  passthrough=()
  [[ -n ${TMUX:-} ]] && passthrough=(--passthrough=tmux)
  chafa --probe=off --polite=on --animate=off -f kitty "${passthrough[@]}" -s "$dim" -- "$file"
  exit
fi

if [[ $mime =~ =binary ]]; then
  file --brief --dereference -- "$file"
  exit
fi

bat_cmd="bat"
command -v batcat >/dev/null 2>&1 && bat_cmd="batcat"

if command -v "$bat_cmd" >/dev/null 2>&1; then
  "$bat_cmd" --style="${BAT_STYLE:-numbers}" --color=always --pager=never \
    --line-range :500 --highlight-line="$center" -- "$file"
else
  sed -n '1,500p' "$file"
fi
