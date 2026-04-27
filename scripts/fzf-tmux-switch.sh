#!/bin/bash

# 1. Define Gruvbox TrueColor escape sequences (Replaced Bold with Orange)
C_ACT=$'\033[38;2;254;128;25m'   # Orange (#fe8019) for Attached
C_SESS=$'\033[38;2;211;134;155m' # Purple (#d3869b)
C_WIN=$'\033[38;2;184;187;38m'   # Green (#b8bb26)
C_CMD=$'\033[38;2;142;192;124m'  # Aqua/Cyan (#8ec07c)
C_DIM=$'\033[38;2;146;131;116m'  # Gray (#928374)
C_RST=$'\033[0m'                 # Reset formatting

targets=""

# 2. Loop through every session
# We use a hidden flag ('1') from tmux to tell us if the session is attached
while IFS=$'\t' read -r session is_attached; do

    # 3. Apply Orange color ONLY if the session is currently attached
    if [[ -n "$is_attached" ]]; then
        session_text="${C_ACT} ${session}${C_RST}"
    else
        session_text="${C_SESS} ${session}${C_RST}"
    fi

    # --- SMART FILTER INTEGRATION START ---
    windows=""
    while IFS=$'\t' read -r w_idx w_name w_cmd w_title w_path w_host; do

        # Get just the current folder name
        w_folder=$(basename "$w_path")

        # We check: Is it empty? OR Is it the bare hostname? OR Does it match the user@host: regex?
        if [[ -z "$w_title" || ( -n "$w_host" && "$w_title" == "$w_host" ) || "$w_title" =~ ^[[:alnum:]_.-]+@[[:alnum:]_.-]+: ]]; then
            title_ui=""
        else
            title_ui=" ${C_DIM}- ${w_title}${C_RST}"
        fi

        # Append the intelligently formatted window to our horizontal string
        windows+="${C_WIN} ${w_idx}:${w_name}${C_RST}  ${C_CMD} ${w_cmd}${C_RST}${title_ui}   "

    # Ask tmux for the trimmed title, path, and hostname to feed our filter logic
    done < <(tmux list-windows -t "$session" -F "#{window_index}	#{window_name}	#{pane_current_command}	#{s/ +$//:pane_title}	#{pane_current_path}	#{host}")
    # --- SMART FILTER INTEGRATION END ---

    # 4. THE FIX: Add a newline ONLY if 'targets' is not empty
    if [[ -n "$targets" ]]; then
        targets+=$'\n'
    fi

    # Construct the final row (without a trailing newline at the end)
    targets+="${session} | ${session_text} | ${windows}"

# We changed the tmux format string to output a hidden '1' instead of '[Attached]'
done < <(tmux list-sessions -F '#{session_name}	#{?session_attached,1,}')

# 3. Pipe into fzf
selected=$(echo "$targets" | fzf \
    --prompt="  workspace: " \
    --ansi \
    --delimiter=" | " \
    --with-nth=2.. \
    --preview 'tmux capture-pane -ep -t {1}'
)

# 4. Execute the switch if a selection was made
if [[ -n "$selected" ]]; then
    # Extract the hidden raw ID from the first column using awk
    target_window=$(echo "$selected" | awk -F ' \\| ' '{print $1}')
    tmux switch-client -t "$target_window"
fi
