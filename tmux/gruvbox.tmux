#!/usr/bin/env bash

# Palette {{{

_set_color () {
    local color_name="@gruvbox_$1"
    local color_24_bit=$2
    local color_8_bit="colour$3"
    if [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]
    then
        tmux set-option -g $color_name $color_24_bit
    else
        tmux set-option -g $color_name $color_8_bit
    fi
}

# Gruvbox color from gruvbox community
_set_color dark0_hard      '#1d2021'  234     # 29-32-33
_set_color dark0           '#282828'  235     # 40-40-40
_set_color dark0_soft      '#32302f'  236     # 50-48-47
_set_color dark1           '#3c3836'  237     # 60-56-54
_set_color dark2           '#504945'  239     # 80-73-69
_set_color dark3           '#665c54'  241     # 102-92-84
_set_color dark4           '#7c6f64'  243     # 124-111-100
_set_color dark4_256       '#7c6f64'  243     # 124-111-100
_set_color gray_245        '#928374'  245     # 146-131-116
_set_color gray_244        '#928374'  244     # 146-131-116
_set_color light0_hard     '#f9f5d7'  230     # 249-245-215
_set_color light0          '#fbf1c7'  229     # 253-244-193
_set_color light0_soft     '#f2e5bc'  228     # 242-229-188
_set_color light1          '#ebdbb2'  223     # 235-219-178
_set_color light2          '#d5c4a1'  250     # 213-196-161
_set_color light3          '#bdae93'  248     # 189-174-147
_set_color light4          '#a89984'  246     # 168-153-132
_set_color light4_256      '#a89984'  246     # 168-153-132
_set_color bright_red      '#fb4934'  167     # 251-73-52
_set_color bright_green    '#b8bb26'  142     # 184-187-38
_set_color bright_yellow   '#fabd2f'  214     # 250-189-47
_set_color bright_blue     '#83a598'  109     # 131-165-152
_set_color bright_purple   '#d3869b'  175     # 211-134-155
_set_color bright_aqua     '#8ec07c'  108     # 142-192-124
_set_color bright_orange   '#fe8019'  208     # 254-128-25
_set_color neutral_red     '#cc241d'  124     # 204-36-29
_set_color neutral_green   '#98971a'  106     # 152-151-26
_set_color neutral_yellow  '#d79921'  172     # 215-153-33
_set_color neutral_blue    '#458588'  66      # 69-133-136
_set_color neutral_purple  '#b16286'  132     # 177-98-134
_set_color neutral_aqua    '#689d6a'  72      # 104-157-106
_set_color neutral_orange  '#d65d0e'  166     # 214-93-14
_set_color faded_red       '#9d0006'  88      # 157-0-6
_set_color faded_green     '#79740e'  100     # 121-116-14
_set_color faded_yellow    '#b57614'  136     # 181-118-20
_set_color faded_blue      '#076678'  24      # 7-102-120
_set_color faded_purple    '#8f3f71'  96      # 143-63-113
_set_color faded_aqua      '#427b58'  65      # 66-123-88
_set_color faded_orange    '#af3a03'  130     # 175-58-3

#}}}
