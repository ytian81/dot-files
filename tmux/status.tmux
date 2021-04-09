#!/usr/bin/env bash

# Helper function {{{

_make_window_section () {
    if [[ "$#" != 4 ]]
    then
        return
    fi

    # Use status line background color
    local bg="$(tmux show-option -gv status-style | sed 's/fg=\(.*\),bg=\(.*\)/\2/')"
    local ffg="#{@gruvbox_$1}"; shift
    local fbg="#{@gruvbox_$1}"; shift

    local bold
    local bold_option=$1; shift
    if [[ $bold_option == "bold" ]]
    then
        bold=",bold"
    fi

    local status_section

    # Always have head 
    status_section="${status_section}#[fg=$bg,bg=$fbg]"

    # Content
    status_section="${status_section}#[fg=$ffg,bg=$fbg$bold]$1"

    # Always have tail 
    status_section="${status_section}#[fg=$fbg,bg=$bg]"

    echo "$status_section"
}

_make_session_section () {
    if [[ "$#" != 5 ]]
    then
        return
    fi

    # Use status line background color
    local bg="$(tmux show-option -gv status-style | sed 's/fg=\(.*\),bg=\(.*\)/\2/')"
    local ffg="#{@gruvbox_$1}"; shift
    local fbg="#{@gruvbox_$1}"; shift
    local affg="#{@gruvbox_$1}"; shift
    local afbg="#{@gruvbox_$1}"; shift

    local status_section

    # Content
    status_section="${status_section}#{?client_prefix,#[fg=$affg]#[bg=$afbg]$1,#[fg=$ffg]#[bg=$fbg]$1}"

    # Always have tail 
    status_section="${status_section}#{?client_prefix,#[fg=$afbg]#[bg=$bg],#[fg=$fbg]#[bg=$bg]}"

    echo "$status_section"
}

_make_right_section () {
    if [[ "$#" != 4 ]]
    then
        return
    fi

    local bg="$(tmux show-option -gv status-style | sed 's/fg=\(.*\),bg=\(.*\)/\2/')"
    local ffg="#{@gruvbox_$1}"; shift
    local fbg="#{@gruvbox_$1}"; shift

    local tbg
    local tail_option="$1"; shift
    if [[ "$tail_option" == "tail" ]]
    then
        tbg=$bg
    else
        tbg="#{@gruvbox_$tail_option}"
    fi

    local status_section

    # Content
    status_section="#[fg=$ffg,bg=$fbg]$1${status_section}"

    # Always have tail 
    status_section="#[fg=$fbg,bg=$tbg]${status_section}"

    echo "$status_section"
}

# }}}
# Status color {{{

tmux set-option -gF status-style        "fg=#{@gruvbox_light1},    bg=#{@gruvbox_dark0_hard}"

# }}}
# Status window {{{

tmux set-option -g window-status-separator ""
tmux set-option -g window-status-format         "$(_make_window_section light1     dark2          no_bold ' #I  #W ')"
tmux set-option -g window-status-current-format "$(_make_window_section dark0_hard neutral_yellow bold    ' #I  #W ')"

# }}}
# Status left {{{

tmux set-option -g status-justify "left"
tmux set-option -g status-left-length "50"
tmux set-option -g status-left                  "$(_make_session_section light3 dark3 dark0_hard neutral_aqua ' #S ')"

# }}}
# Status right {{{

# dynamically change status right length
tmux set-option -g status-right-length "300"
tmux set-option -g status-right "\
#{pomodoro_status}\
$(_make_right_section light4 dark1 tail  ' #{sysstat_cpu}')\
$(_make_right_section light4 dark1 dark1  ' #{sysstat_mem}')\
$(_make_right_section light4 dark1 dark1  ' #{sysstat_swap}')\
$(_make_right_section light4 dark1 dark1  ' #{sysstat_loadavg} ')\
$(_make_right_section light4 dark2 dark1  '#{simple_git_status}')\
$(_make_right_section light2 dark3 dark2 ' #{battery_icon_status} - #{battery_icon_charge} #{battery_percentage} #{battery_remain} ')\
$(_make_right_section light2 dark4 dark3 ' %b %d  %H:%M') "

# }}}

# vim:filetype=tmux:foldmethod=marker
