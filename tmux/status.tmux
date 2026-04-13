#!/usr/bin/env bash
# status.tmux — Status line configuration (data + layout)
#
# This file declares WHAT to show. The engine (status-engine.tmux) decides
# HOW to render it (padding, separators, colors). Module text should be
# bare content — no leading/trailing spaces.
#
# vim:filetype=bash:foldmethod=marker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Separator style ──────────────────────────────────────────────────────
# Global default. Individual modules can override with mod_<name>_style.
# _separator_style="pill"

# ── Load engine ──────────────────────────────────────────────────────────
source "$SCRIPT_DIR/status-engine.tmux"

# ── Icons ────────────────────────────────────────────────────────────────
_icon_zoom=🔍
_icon_lock=

# ── Module definitions ──────────────────────────────────────────────────{{
#
# Properties:
#   text        — bare content (engine adds padding)
#   fg / bg     — gruvbox color names
#   bold        — "yes" or "no"
#   priority    — 0 = always visible; higher = survives longer when narrow
#   width       — estimated rendered columns (for auto-computing thresholds)
#   text_short  — optional abbreviated form
#   style       — per-module override: "powerline" or "pill"

# Session (tri-state: normal / prefix / copy-mode)
mod_session_text="#S"
mod_session_fg="light3"
mod_session_bg="dark3"
mod_session_prefix_fg="dark0_hard"
mod_session_prefix_bg="neutral_aqua"
mod_session_copy_fg="dark0_hard"
mod_session_copy_bg="bright_orange"
mod_session_width=6

# Git status (via gitstatusd)
mod_git_text="#{gitstatusd}"
mod_git_fg="light4"
mod_git_bg="dark2"
mod_git_priority=2
mod_git_width=20

# Window tabs
mod_window_text="#I ${_sep_thin} #W#{?window_zoomed_flag, ${_icon_zoom},}"
mod_window_fg="light1"
mod_window_bg="dark2"

mod_window_current_text="#I ${_sep_thin} #W#{?window_zoomed_flag, ${_icon_zoom},} #{?#{==:#{client_key_table},WINDOW},${_icon_lock},}"
mod_window_current_fg="dark0_hard"
mod_window_current_bg="neutral_yellow"
mod_window_current_bold="yes"

# Pomodoro (raw — plugin handles its own styling)
mod_pomodoro_text="#{pomodoro_status} "
mod_pomodoro_raw="yes"

# CPU
mod_cpu_text="#{sysstat_cpu}"
mod_cpu_fg="light4"
mod_cpu_bg="dark1"
mod_cpu_priority=1
mod_cpu_width=8

# Memory
mod_mem_text="#{sysstat_mem}"
mod_mem_fg="light4"
mod_mem_bg="dark1"
mod_mem_priority=1
mod_mem_width=8

# Swap
mod_swap_text="#{sysstat_swap}"
mod_swap_fg="light4"
mod_swap_bg="dark1"
mod_swap_priority=1
mod_swap_width=8

# Load average
mod_loadavg_text="#{sysstat_loadavg}"
mod_loadavg_fg="light4"
mod_loadavg_bg="dark2"
mod_loadavg_priority=1
mod_loadavg_width=10

# Battery
mod_battery_text="#{battery_icon_status} - #{battery_icon_charge} #{battery_percentage} #{battery_remain}"
mod_battery_text_short="#{battery_icon_charge} #{battery_percentage}"
mod_battery_fg="light2"
mod_battery_bg="dark3"
mod_battery_priority=0
mod_battery_width=25
mod_battery_width_short=10

# Date/time
mod_datetime_text="%b %d  %H:%M"
mod_datetime_text_short="%H:%M"
mod_datetime_fg="light2"
mod_datetime_bg="dark4"
mod_datetime_priority=0
mod_datetime_width=14
mod_datetime_width_short=7

# }}
# ── Layout ──────────────────────────────────────────────────────────────{{

layout_left=(session git)
layout_right=(pomodoro cpu mem swap loadavg battery datetime)

# }}
# ── Apply ────────────────────────────────────────────────────────────────

tmux set-option -g status-position top
tmux set-option -gF status-style "fg=#{@gruvbox_light1}, bg=#{@gruvbox_dark0_soft}"

status_engine_apply
