#!/usr/bin/env zsh
# =============================================================================
# fzf-tmux-switch.sh: Interactive Gruvbox TUI session switcher for tmux.
# =============================================================================

export PATH="$HOME/.fzf/bin:$HOME/.local/bin:$PATH"

# Gruvbox TrueColor ANSI palette (no '1;' bold so fzf's selected-row attribute merging preserves TrueColor)
C_ACT=$'\033[38;2;254;128;25m'      # Orange (#fe8019) — Attached session
C_SESS=$'\033[38;2;211;134;155m'    # Purple (#d3869b) — Detached session
C_WIN=$'\033[38;2;184;187;38m'      # Green (#b8bb26)  — Active window
C_WIN_DIM=$'\033[38;2;168;153;132m' # Light4 (#a89984) — Inactive window
C_CMD=$'\033[38;2;142;192;124m'     # Aqua (#8ec07c)   — Foreground command
C_BLUE=$'\033[38;2;131;165;152m'    # Blue (#83a598)   — Pane count / cwd
C_YLW=$'\033[38;2;250;189;47m'      # Yellow (#fabd2f) — Reviewing / alert
C_FG2=$'\033[38;2;213;196;161m'     # Light2 (#d5c4a1)      — Title text
C_DIM=$'\033[38;2;146;131;116m'     # Gray (#928374)        — Muted metadata
C_BORDER=$'\033[38;2;102;92;84m'    # Dark3 (#665c54)       — Column & rule dividers
C_RST=$'\033[0m'

# Format a single window's title with semantic Gruvbox highlights
_format_title() {
    local w_title="$1" w_host="$2"
    if [[ -z "$w_title" || ( -n "$w_host" && "$w_title" == "$w_host" ) || "$w_title" =~ ^[[:alnum:]_.-]+@[[:alnum:]_.-]+: ]]; then
        REPLY=""
        return
    fi
    if [[ "$w_title" == *:\ READY* ]]; then
        local rest="${w_title#*: READY}"
        REPLY=" ${C_BORDER}—${C_RST} ${C_WIN}READY${C_RST}${C_FG2}${rest}${C_RST}"
    elif [[ "$w_title" == *:\ REVIEWING* ]]; then
        local rest="${w_title#*: REVIEWING}"
        REPLY=" ${C_BORDER}—${C_RST} ${C_YLW}REVIEWING${C_RST}${C_FG2}${rest}${C_RST}"
    elif [[ "$w_title" == *:\ * ]]; then
        local rest="${w_title#*: }"
        REPLY=" ${C_BORDER}—${C_RST} ${C_CMD}${rest}${C_RST}"
    else
        REPLY=" ${C_BORDER}—${C_RST} ${C_FG2}${w_title}${C_RST}"
    fi
}

# Mode 1: Generate aligned session rows for fzf (--list)
_generate_list() {
    setopt localoptions extendedglob
    typeset -A sess_bell sess_slot_count slot_max
    typeset -A sess_slots sess_slot_len
    local s_name w_idx p_idx w_name w_act p_act w_cmd w_title w_path w_host w_bell w_zoom w_panes
    local cmd_ui zoom_ui title_ui win_entry entry_id entry_name plain_entry
    local idx vlen

    # Single-pass query across all panes in all sessions (zero per-session forks)
    while IFS=$'\t' read -r s_name w_idx p_idx w_name w_act p_act w_cmd w_title w_path w_host w_bell w_zoom w_panes; do
        [[ -z "$s_name" ]] && continue

        if [[ "$w_bell" == "1" ]]; then
            sess_bell[$s_name]=1
        fi

        zoom_ui=""
        [[ "$w_zoom" == "1" && "$p_act" == "1" ]] && zoom_ui=" 🔍"

        if (( w_panes > 1 )); then
            entry_id="${w_idx}.${p_idx}"
            entry_name="${w_cmd:-$w_name}"
            cmd_ui=""
        else
            entry_id="${w_idx}"
            entry_name="${w_name}"
            cmd_ui=""
            if [[ -n "$w_cmd" && "$w_cmd" != "$w_name" ]]; then
                cmd_ui=" ${C_CMD} ${w_cmd}${C_RST}"
            fi
        fi

        _format_title "$w_title" "$w_host"
        title_ui="$REPLY"

        if [[ "$w_act" == "1" && "$p_act" == "1" ]]; then
            win_entry="${C_WIN} ${entry_id}:${entry_name}${C_RST}${cmd_ui}${zoom_ui}${title_ui}"
        else
            win_entry="${C_WIN_DIM} ${entry_id}:${entry_name}${C_RST}${cmd_ui}${zoom_ui}${title_ui}"
        fi

        plain_entry="${win_entry//$'\033'\[[0-9;]##m/}"
        vlen=${#plain_entry}
        [[ "$zoom_ui" == *"🔍"* ]] && (( vlen += 1 ))

        idx=$(( ${sess_slot_count[$s_name]:-0} + 1 ))
        sess_slot_count[$s_name]=$idx
        sess_slots[${s_name}:${idx}]="$win_entry"
        sess_slot_len[${s_name}:${idx}]=$vlen
        if (( vlen > ${slot_max[$idx]:-0} )); then
            slot_max[$idx]=$vlen
        fi
    done < <(tmux list-panes -a -F $'#{session_name}\t#{window_index}\t#{pane_index}\t#{window_name}\t#{?window_active,1,0}\t#{?pane_active,1,0}\t#{pane_current_command}\t#{s/ +$//:pane_title}\t#{pane_current_path}\t#{host}\t#{window_bell_flag}\t#{?window_zoomed_flag,1,0}\t#{window_panes}' 2>/dev/null)

    # Collect sessions sorted with attached first, then most recently attached
    local -a sess_rows
    local max_len=16
    local is_att last_att session
    while IFS=$'\t' read -r is_att last_att session; do
        [[ -z "$session" ]] && continue
        sess_rows+=("${is_att}"$'\t'"${session}")
        (( ${#session} > max_len )) && max_len=${#session}
    done < <(tmux list-sessions -F $'#{?session_attached,1,0}\t#{?session_last_attached,#{session_last_attached},0}\t#{session_name}' 2>/dev/null | sort -t$'\t' -k1,1nr -k2,2nr)

    (( max_len > 44 )) && max_len=44

    local row padded_sess sess_col bell_col win_line count k pad_len
    for row in "${sess_rows[@]}"; do
        is_att="${row%%$'\t'*}"
        session="${row#*$'\t'}"
        padded_sess="${(r:max_len:)session}"

        if [[ "$is_att" == "1" ]]; then
            sess_col="${C_ACT}●  ${padded_sess}${C_RST}"
        else
            sess_col="  ${C_SESS} ${padded_sess}${C_RST}"
        fi

        if [[ -n "${sess_bell[$session]}" ]]; then
            bell_col="🔔"
        else
            bell_col="  "
        fi

        count=${sess_slot_count[$session]:-0}
        win_line=""
        for (( k = 1; k <= count; k++ )); do
            win_entry="${sess_slots[${session}:${k}]}"
            if (( k < count )); then
                pad_len=$(( ${slot_max[$k]:-0} - ${sess_slot_len[${session}:${k}]:-0} + 3 ))
                (( pad_len < 3 )) && pad_len=3
                win_line+="${win_entry}${(l:pad_len:: :)}"
            else
                win_line+="${win_entry}"
            fi
        done

        printf "%s\t%s  %s  %s\n" \
            "$session" \
            "$sess_col" \
            "$bell_col" \
            "$win_line"
    done
}

STATE_FILE="/tmp/fzf-tmux-preview-pane"

# Cycle the previewed pane for a target session (+1 or -1)
_cycle_pane() {
    local target="$1" delta="${2:-1}"
    [[ -z "$target" ]] && return 0

    local -a panes
    local wp w_act p_act active_wp=""
    while IFS=$'\t' read -r wp w_act p_act; do
        [[ -z "$wp" ]] && continue
        panes+=("$wp")
        [[ "$w_act" == "1" && "$p_act" == "1" ]] && active_wp="$wp"
    done < <(tmux list-panes -s -t "$target" -F $'#{window_index}.#{pane_index}\t#{?window_active,1,0}\t#{?pane_active,1,0}' 2>/dev/null)

    local count=${#panes[@]}
    (( count <= 1 )) && return 0

    local cur_wp="$active_wp"
    if [[ -r "$STATE_FILE" ]]; then
        local saved_sess saved_wp
        IFS=$'\t' read -r saved_sess saved_wp < "$STATE_FILE"
        [[ "$saved_sess" == "$target" && -n "$saved_wp" ]] && cur_wp="$saved_wp"
    fi

    local idx=1 i
    for (( i = 1; i <= count; i++ )); do
        if [[ "${panes[$i]}" == "$cur_wp" ]]; then
            idx=$i
            break
        fi
    done

    local next_idx=$(( (idx - 1 + delta + count) % count + 1 ))
    printf "%s\t%s\n" "$target" "${panes[$next_idx]}" > "$STATE_FILE"
}

# Build a single preview frame for target session
_capture_preview_frame() {
    local target="$1"
    local wp w_idx w_name w_cmd w_path w_act p_act w_panes
    local -a p_wps p_labels p_paths p_is_act
    local active_wp=""

    while IFS=$'\t' read -r wp w_idx w_name w_cmd w_path w_act p_act w_panes; do
        [[ -z "$wp" ]] && continue
        p_wps+=("$wp")
        if (( w_panes > 1 )); then
            local pane_label="$w_cmd"
            [[ -z "$pane_label" ]] && pane_label="$w_name"
            p_labels+=("${wp}:${pane_label}")
        else
            p_labels+=("${w_idx}:${w_name}")
        fi
        p_paths+=("$w_path")
        if [[ "$w_act" == "1" && "$p_act" == "1" ]]; then
            p_is_act+=("1")
            active_wp="$wp"
        else
            p_is_act+=("0")
        fi
    done < <(tmux list-panes -s -t "$target" -F $'#{window_index}.#{pane_index}\t#{window_index}\t#{window_name}\t#{pane_current_command}\t#{pane_current_path}\t#{?window_active,1,0}\t#{?pane_active,1,0}\t#{window_panes}' 2>/dev/null)

    local preview_wp="$active_wp"
    if [[ -r "$STATE_FILE" ]]; then
        local saved_sess saved_wp
        IFS=$'\t' read -r saved_sess saved_wp < "$STATE_FILE"
        if [[ "$saved_sess" == "$target" && -n "$saved_wp" ]]; then
            preview_wp="$saved_wp"
        fi
    fi

    local total_panes=${#p_wps[@]}
    local active_cwd="" win_badges="" i
    for (( i = 1; i <= total_panes; i++ )); do
        local cur="${p_wps[$i]}"
        local lbl="${p_labels[$i]}"
        local act_mark=""
        if (( total_panes > 1 )) && [[ "${p_is_act[$i]}" == "1" ]]; then
            act_mark="● "
        fi
        if [[ "$cur" == "$preview_wp" ]]; then
            active_cwd="${p_paths[$i]}"
            win_badges+="${C_WIN}[${act_mark}${lbl}]${C_RST} "
        else
            win_badges+="${C_DIM}${act_mark}${lbl}${C_RST} "
        fi
    done

    # Shorten HOME path for clean display
    active_cwd="${active_cwd/#$HOME/\~}"

    local rule_w="${FZF_PREVIEW_COLUMNS:-96}"
    local rule_str="${(l:$rule_w::─:)}"
    printf "%s %s%s  %s│%s  %s %s%s  %s│%s  %s\n" \
        "$C_SESS" "$target" "$C_RST" \
        "$C_BORDER" "$C_RST" \
        "$C_BLUE" "${active_cwd:-~}" "$C_RST" \
        "$C_BORDER" "$C_RST" \
        "$win_badges"
    printf "%s%s%s\n" "$C_BORDER" "$rule_str" "$C_RST"

    if [[ -n "$preview_wp" ]]; then
        tmux capture-pane -ep -t "${target}:${preview_wp}" 2>/dev/null | awk 'NF {p=1} p'
    else
        tmux capture-pane -ep -t "$target" 2>/dev/null | awk 'NF {p=1} p'
    fi
}

# Mode 2: Live-streaming session preview (--preview)
# Renders the first frame immediately (0ms delay), then polls every 500ms
# using zsh's builtin zselect and only redraws (\033[2J) when output changes.
_render_preview() {
    local target="$1"
    [[ -z "$target" ]] && return 0

    zmodload zsh/zselect 2>/dev/null || true

    local last_frame frame
    last_frame="$(_capture_preview_frame "$target")"
    printf "%s\n" "$last_frame"

    while zselect -t 50 2>/dev/null || sleep 0.5; do
        frame="$(_capture_preview_frame "$target")"
        if [[ -n "$frame" && "$frame" != "$last_frame" ]]; then
            printf "\033[2J%s\n" "$frame"
            last_frame="$frame"
        fi
    done
}

case "${1:-}" in
    --list)
        _generate_list
        exit 0
        ;;
    --preview)
        _render_preview "${2:-}"
        exit 0
        ;;
    --cycle-pane)
        _cycle_pane "${2:-}" "${3:-1}"
        exit 0
        ;;
esac

rm -f "$STATE_FILE" 2>/dev/null || true

SELF_PATH="${0:A}"
HEADER_TEXT=$'\e[94m\e[0m \e[38;5;208mEnter\e[0m switch  \e[38;5;208mTAB/S-TAB\e[0m switch pane  \e[38;5;208mCTRL-R\e[0m reload  \e[38;5;208mCTRL-X\e[0m kill session  \e[38;5;208mCTRL-/\e[0m toggle preview'

selected=$(
    _generate_list | fzf \
        --ansi \
        --delimiter=$'\t' \
        --with-nth=2.. \
        --input-label='   tmux sessions ' \
        --preview-label='   pane preview ' \
        --header="$HEADER_TEXT" \
        --preview="\"$SELF_PATH\" --preview {1}" \
        --preview-window='down,55%,follow,~2' \
        --bind="enter:become(echo {1})" \
        --bind="tab:execute-silent(\"$SELF_PATH\" --cycle-pane {1} 1)+refresh-preview" \
        --bind="btab:execute-silent(\"$SELF_PATH\" --cycle-pane {1} -1)+refresh-preview" \
        --bind="ctrl-/:change-preview-window(right,55%,follow,~2|hidden|down,55%,follow,~2)" \
        --bind="ctrl-r:reload(\"$SELF_PATH\" --list)" \
        --bind="ctrl-x:execute-silent(tmux kill-session -t {1} 2>/dev/null)+reload(\"$SELF_PATH\" --list)"
)

if [[ -n "$selected" ]]; then
    target_switch="$selected"
    if [[ -r "$STATE_FILE" ]]; then
        IFS=$'\t' read -r saved_sess saved_wp < "$STATE_FILE"
        if [[ "$saved_sess" == "$selected" && -n "$saved_wp" ]]; then
            target_switch="${selected}:${saved_wp}"
        fi
    fi
    rm -f "$STATE_FILE" 2>/dev/null || true
    tmux switch-client -t "$target_switch"
fi
