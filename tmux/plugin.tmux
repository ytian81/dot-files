#!/usr/bin/env bash

# tmux-plugins/tmux-battery {{{

tmux set-option -g @batt_remain_short true
tmux set-option -g @batt_icon_charge_tier8 '🌕'
tmux set-option -g @batt_icon_charge_tier7 '🌖'
tmux set-option -g @batt_icon_charge_tier6 '🌖'
tmux set-option -g @batt_icon_charge_tier5 '🌗'
tmux set-option -g @batt_icon_charge_tier4 '🌗'
tmux set-option -g @batt_icon_charge_tier3 '🌘'
tmux set-option -g @batt_icon_charge_tier2 '🌘'
tmux set-option -g @batt_icon_charge_tier1 '🌑'

# }}}
# tmux-plugins/tmux-logging {{{

tmux set-option -g @logging-path "/tmp"

# }}}
# samoshkin/tmux-plugin-sysstat {{{

tmux set-option -g @sysstat_cpu_color_low "#{@gruvbox_neutral_green}"
tmux set-option -g @sysstat_cpu_color_medium "#{@gruvbox_neutral_yellow}"
tmux set-option -g @sysstat_cpu_color_stress "#{@gruvbox_neutral_red}"
tmux set-option -g @sysstat_mem_color_low "#{@gruvbox_neutral_green}"
tmux set-option -g @sysstat_mem_color_medium "#{@gruvbox_neutral_yellow}"
tmux set-option -g @sysstat_mem_color_stress "#{@gruvbox_neutral_red}"
tmux set-option -g @sysstat_swap_color_low "#{@gruvbox_neutral_green}"
tmux set-option -g @sysstat_swap_color_medium "#{@gruvbox_neutral_yellow}"
tmux set-option -g @sysstat_swap_color_stress "#{@gruvbox_neutral_red}"

# }}}
# ytian/tmux-pomodoro {{{

tmux set-option -g @pomodoro_minutes 1
tmux set-option -g @pomodoro_hook "tmux clock-mode"

# }}}

# vim:filetype=tmux:foldmethod=marker
