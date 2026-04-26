#!/usr/bin/env bash
# status-engine.tmux — Formatting engine for tmux status line
#
# Renders powerline-arrow or pill-capsule status sections from module
# declarations. The config file (status.tmux) declares data; this file
# handles all visual formatting.
#
# REQUIRES: tmux >= 3.4
#   - tmux 3.2+: #{e|>=:} numeric comparison in formats
#   - tmux 3.4+: #[push-default] / #[pop-default] (see "DEFAULT STYLE STACK")
#
# HOW IT WORKS
# ============
#
# 1. The config file declares modules as bash variables:
#      mod_<name>_text      — tmux format string (bare content, no padding)
#      mod_<name>_fg        — gruvbox color name for text
#      mod_<name>_bg        — gruvbox color name for background
#      mod_<name>_bold      — "yes" or "no"
#      mod_<name>_priority  — collapse priority (0 = always visible)
#      mod_<name>_width     — estimated column width (for auto thresholds)
#      mod_<name>_text_short — optional abbreviated text
#      mod_<name>_style     — "powerline" or "pill" (overrides global default)
#      mod_<name>_raw       — "yes" to inject text without formatting
#
# 2. The config file defines layout arrays:
#      layout_left=(session git)
#      layout_right=(pomodoro cpu mem swap loadavg battery datetime)
#
# 3. The config calls status_engine_apply, which:
#      a) Computes collapse thresholds from module widths
#      b) Renders each module with the appropriate style
#      c) Chains separator colors between adjacent modules
#      d) Sets tmux options (status-left, status-right, window-status-*)
#
# SEPARATOR STYLES
# ================
#
# Powerline (arrows):
#   Left sections:  [content ][content ]
#   Right sections: [ content][ content]
#   The arrow's fg = this section's bg, arrow's bg = neighbor's bg.
#   This creates the "flowing into each other" visual.
#
# Pill (rounded capsules):
#   All sections:   [ content ]  [ content ]
#   Each section is self-contained. Open glyph fg = section bg,
#   close glyph fg = section bg, both against status-line bg.
#
# COMMA ESCAPING
# ==============
#
# tmux's #{?condition,true_branch,false_branch} format uses commas as
# delimiters. Style attributes like #[fg=red,bg=blue] also contain commas.
# When a style is INSIDE a conditional, the comma in #[fg=X,bg=Y] would be
# misinterpreted as a branch separator. The escape sequence #, tells tmux
# "this comma is literal, not a delimiter."
#
# IMPORTANT: #, MUST ONLY be used inside #{?...} conditionals.
# Outside conditionals, use bare commas. Some tmux versions (notably 3.6)
# may misrender #, when it appears outside a conditional context.
#
# In this engine:
#   - Collapsible modules (priority > 0) are wrapped in #{?...} by
#     _collapse_wrap, so their styles use #, (escaped commas).
#   - Always-visible modules (priority = 0) are NOT wrapped, so their
#     styles use bare commas.
#   - The "escape_comma" parameter controls which style is used.
#
# DEFAULT STYLE STACK (push-default / pop-default)
# ================================================
#
# Some plugins (e.g. tmux-plugin-sysstat: CPU/MEM/SWAP/LOADAVG) emit
# #[default] inside their content — for example:
#   CPU:#[fg=green]42.0%#[default]
# By itself, #[default] resets to the GLOBAL status-line default style,
# breaking the surrounding section's fg/bg.
#
# tmux 3.4 adds #[push-default] / #[pop-default], which save and restore
# the "default" style on a stack. By wrapping each module's content as:
#   #[fg=X,bg=Y,push-default] $text#[default] #[pop-default]
# we make the section's fg/bg the LOCAL default for the duration of $text.
# Any #[default] inside $text now resets to the section style, not to the
# status-line global.
#
# Layout details that matter:
#   - push-default must come AFTER fg/bg so the saved default reflects
#     the section style.
#   - The #[default] BEFORE the trailing pad-space covers plugins that
#     don't reset their own style — it forces the pad-space into section
#     colors.
#   - pop-default must come AFTER the trailing pad-space. tmux's
#     pop-default also resets the ACTIVE style to the popped default
#     (i.e. global), so anything between #[default] and #[pop-default]
#     would render in the global status-line style. Keep the pad-space
#     inside the push/pop scope.
#
# This is plugin-agnostic — works for any current or future module whose
# text contains a style reset.
#
# PRIORITY-BASED COLLAPSE
# =======================
#
# Each module declares a priority (0 = always visible, higher = more
# important). The engine computes a COLLAPSE_THRESHOLD for each priority
# level based on the sum of module widths. At render time, tmux evaluates
# #{e|>=:#{window_width},threshold} and shows/hides sections accordingly.
# This happens on every resize — no re-sourcing needed.
#
# Three collapse states per module:
#   1. Full:   window >= threshold        → show mod_<name>_text
#   2. Short:  threshold > window >= med  → show mod_<name>_text_short
#   3. Hidden: window < med              → show nothing
#
# vim:filetype=bash:foldmethod=marker

# ── Global separator style ──────────────────────────────────────────────{{
# Set to "powerline" or "pill". Can be overridden per-module with
# mod_<name>_style. Default: "powerline".
: "${_separator_style:=powerline}"
# }}

# ── Separator glyphs ────────────────────────────────────────────────────{{
# These are Powerline/Nerd Font characters. Override before sourcing
# if you use different glyphs. All are defined regardless of style
# so that per-module style mixing works.
: "${_sep_right:=}"            # U+E0B0: right-pointing arrow (powerline left/window sections)
: "${_sep_left:=}"             # U+E0B2: left-pointing arrow (powerline right sections)
: "${_sep_pill_open:=}"        # U+E0B6: left half-circle (pill open)
: "${_sep_pill_close:=}"       # U+E0B4: right half-circle (pill close)
: "${_sep_right_thin:=}"       # U+E0B1: thin right separator (decorative, used in window text)
: "${_sep_left_thin:=}"        # U+E0B3: thin left separator (decorative)
# }}

# ── Color resolver ──────────────────────────────────────────────────────{{
# Converts a color name (e.g. "dark1") into a tmux format reference
# (e.g. "#{@gruvbox_dark1}"). Override this function for other themes.
_resolve_color() { echo "#{@gruvbox_$1}"; }
# }}

# ── Helpers ─────────────────────────────────────────────────────────────{{

# Returns the resolved bg color of the tmux status line (e.g. "colour236").
_status_bg() {
  tmux show-option -gv status-style | sed 's/.*bg=\([^,]*\).*/\1/'
}

# Wraps $content in a tmux conditional that only renders when
# window_width >= threshold. Returns $content unchanged if threshold is 0.
#
# Uses tmux 3.2+ numeric comparison: #{e|>=:value,threshold}
# (replaces the old regex hack #{m/ri:^[0-9][0-9][0-9]$,...})
_width_guard() {
  local threshold="$1" content="$2"
  [[ -z "$threshold" || "$threshold" == "0" ]] && { echo "$content"; return; }
  echo "#{?#{e|>=:#{window_width},${threshold}},$content,}"
}

# Auto-computes COLLAPSE_THRESHOLD_<N> for each priority level.
#
# Walks all modules in the layout, sums their estimated widths
# (mod_<name>_width) grouped by priority. The threshold for priority N
# = total width of all always-visible modules + all modules with
# priority >= N. This is the minimum window width at which priority-N
# modules should be shown.
#
# Example result:
#   COLLAPSE_THRESHOLD_1=115  (show sysstat when window >= 115 cols)
#   COLLAPSE_THRESHOLD_2=73   (show git when window >= 73 cols)
_compute_thresholds() {
  local side="$1"; shift
  local modules=("$@")
  local -A priority_widths  # priority → total width of that group
  local always_width=0      # total width of priority-0 modules

  for name in "${modules[@]}"; do
    local raw_var="mod_${name}_raw"
    [[ "${!raw_var}" == "yes" ]] && continue  # skip raw modules
    [[ "$name" == "session" ]] && continue       # session handled separately

    local w_var="mod_${name}_width"; local w="${!w_var:-0}"
    local pri_var="mod_${name}_priority"; local pri="${!pri_var:-0}"
    local sep_overhead=2  # ~2 cols for separator + padding

    if [[ "$pri" == "0" ]]; then
      always_width=$((always_width + w + sep_overhead))
    else
      priority_widths[$pri]=$((${priority_widths[$pri]:-0} + w + sep_overhead))
    fi
  done

  # Add session width (always visible)
  local sw_var="mod_session_width"; local sw="${!sw_var:-6}"
  always_width=$((always_width + sw + 2))

  # Sort priorities descending: highest priority = most important = last to drop
  local sorted_pris=($(echo "${!priority_widths[@]}" | tr ' ' '\n' | sort -rn))

  # Build cumulative thresholds
  local cumulative=$always_width
  for pri in "${sorted_pris[@]}"; do
    cumulative=$((cumulative + priority_widths[$pri]))
    eval "COLLAPSE_THRESHOLD_$pri=$cumulative"
  done
}

# Maps a priority level to its collapse threshold (minimum window width).
# Priority 0 → "0" (never collapse, always visible).
# Priority N → COLLAPSE_THRESHOLD_N (set by _compute_thresholds).
# Falls back to a formula if threshold wasn't computed.
_priority_threshold() {
  local priority="$1"
  case "$priority" in
    0|"") echo "0" ;;
    *)
      local var="COLLAPSE_THRESHOLD_${priority}"
      local val="${!var}"
      if [[ -n "$val" ]]; then
        echo "$val"
      else
        echo "$((120 + priority * 20))"  # fallback formula
      fi
      ;;
  esac
}

# Wraps a rendered section in a tmux width conditional based on its priority.
#
# Three states:
#   priority=0 → always show $full (no wrapping)
#   priority>0, no short text → show $full above threshold, hide below
#   priority>0, with short text → show $full above threshold,
#                                  show $short at medium width, hide below
_collapse_wrap() {
  local priority="$1" full="$2" short="$3"
  local threshold; threshold="$(_priority_threshold "$priority")"

  if [[ "$threshold" == "0" ]]; then
    # Always visible — return the full section as-is (no conditional)
    echo "$full"
  elif [[ -n "$short" ]]; then
    # Three-tier: full → short → hidden
    local short_threshold; short_threshold="$(_priority_threshold $((priority - 1)))"
    [[ "$short_threshold" == "0" ]] && short_threshold="$((threshold - 40))"
    echo "#{?#{e|>=:#{window_width},${threshold}},$full,$(_width_guard "$short_threshold" "$short")}"
  else
    # Two-tier: full → hidden
    _width_guard "$threshold" "$full"
  fi
}

# Returns the separator style for a module.
# Checks mod_<name>_style first, falls back to global _separator_style.
_get_module_style() {
  local name="$1"
  local style_var="mod_${name}_style"
  echo "${!style_var:-$_separator_style}"
}

# }}

# ════════════════════════════════════════════════════════════════════════════
# POWERLINE RENDERERS
# ════════════════════════════════════════════════════════════════════════════
#
# Powerline sections use directional arrow separators.
#
# Left-side sections:
#   #[fg=text_fg, bg=section_bg] content #[fg=section_bg, bg=next_bg]
#   The right arrow () has: fg = THIS section's bg (arrow color),
#   bg = NEXT section's bg (what the arrow points into).
#
# Right-side sections:
#   #[fg=section_bg, bg=prev_bg]#[fg=text_fg, bg=section_bg] content
#   The left arrow () has: fg = THIS section's bg (arrow color),
#   bg = PREVIOUS section's bg (what the arrow points away from).
#
# Window sections (centre):
#   #[fg=text_fg, bg=section_bg] content 
#   Arrows on both sides, both pointing right.
#
# {{

# Renders the session indicator for the left side.
# Special because it has three color states:
#   Normal:       text_fg / section_bg
#   Prefix active: prefix_fg / prefix_bg     (when pressing the tmux prefix)
#   Copy mode:    copy_fg / copy_bg          (when in copy/scroll mode)
#
# $1 = next_bg: the bg color of the section to the RIGHT of session.
#               Used for the arrow separator that closes this section.
_powerline_session() {
  local next_bg="$1"
  local text_fg="$(_resolve_color "$mod_session_fg")"
  local section_bg="$(_resolve_color "$mod_session_bg")"
  local prefix_fg="$(_resolve_color "$mod_session_prefix_fg")"
  local prefix_bg="$(_resolve_color "$mod_session_prefix_bg")"
  local copy_fg="$(_resolve_color "$mod_session_copy_fg")"
  local copy_bg="$(_resolve_color "$mod_session_copy_bg")"
  local text="$mod_session_text"

  # Content: tri-state conditional (prefix → copy → normal)
  local out=""
  out+="#{?client_prefix,#[fg=$prefix_fg#,bg=$prefix_bg] $text ,#{?pane_in_mode,#[fg=$copy_fg#,bg=$copy_bg] $text ,#[fg=$text_fg#,bg=$section_bg] $text }}"

  # Closing arrow: points from this section into the next.
  # Arrow fg = this section's bg (changes with state), arrow bg = next section's bg.
  out+="#{?client_prefix,#[fg=$prefix_bg#,bg=$next_bg]${_sep_right},#{?pane_in_mode,#[fg=$copy_bg#,bg=$next_bg]${_sep_right},#[fg=$section_bg#,bg=$next_bg]${_sep_right}}}"
  echo "$out"
}

# Renders a left-side powerline section.
#
# $1 = module name
# $2 = next_bg: bg color of the section to the RIGHT
_powerline_left() {
  local name="$1" next_bg="$2"
  local fg_var="mod_${name}_fg"         ; local fg="${!fg_var}"
  local bg_var="mod_${name}_bg"         ; local bg="${!bg_var}"
  local bold_var="mod_${name}_bold"     ; local bold="${!bold_var:-no}"
  local text_var="mod_${name}_text"     ; local text="${!text_var}"
  local pri_var="mod_${name}_priority"  ; local priority="${!pri_var:-0}"
  local short_var="mod_${name}_text_short" ; local text_short="${!short_var}"

  local bold_attr=""
  [[ "$bold" == "yes" ]] && bold_attr=",bold"
  local text_fg="$(_resolve_color "$fg")"
  local section_bg="$(_resolve_color "$bg")"

  # Format: #[text style] <space>content<space> #[arrow style]
  # push-default makes the section style the local default so any
  # #[default] emitted from inside $text (e.g. by sysstat) resets to it.
  # See "DEFAULT STYLE STACK" in the file header.
  local full="#[fg=$text_fg,bg=$section_bg$bold_attr]#[push-default] $text#[default] #[pop-default]#[fg=$section_bg,bg=$next_bg]${_sep_right}"
  local short=""
  if [[ -n "$text_short" ]]; then
    short="#[fg=$text_fg,bg=$section_bg$bold_attr]#[push-default] $text_short#[default] #[pop-default]#[fg=$section_bg,bg=$next_bg]${_sep_right}"
  fi

  _collapse_wrap "$priority" "$full" "$short"
}

# Renders a right-side powerline section.
#
# $1 = module name
# $2 = prev_bg: bg color of the section to the LEFT (for the arrow background)
# $3 = escape_comma: "yes" to use #, inside styles (needed when this
#      section's output will be placed inside a #{?...} conditional).
#      "no" to use bare commas (when the output is NOT inside a conditional).
#      See the COMMA ESCAPING section in the file header for details.
_powerline_right() {
  local name="$1" prev_bg="$2" escape_comma="${3:-no}"
  local fg_var="mod_${name}_fg"         ; local fg="${!fg_var}"
  local bg_var="mod_${name}_bg"         ; local bg="${!bg_var}"
  local text_var="mod_${name}_text"     ; local text="${!text_var}"
  local pri_var="mod_${name}_priority"  ; local priority="${!pri_var:-0}"
  local short_var="mod_${name}_text_short" ; local text_short="${!short_var}"

  local text_fg="$(_resolve_color "$fg")"
  local section_bg="$(_resolve_color "$bg")"

  # Choose comma style based on whether output will be inside a conditional.
  # See COMMA ESCAPING in the file header.
  local comma=","
  [[ "$escape_comma" == "yes" ]] && comma="#,"

  # Format: #[arrow style]#[text style] <space>content<space>
  # push-default makes the section style the local default so any
  # #[default] emitted from inside $text (e.g. by sysstat) resets to it.
  # See "DEFAULT STYLE STACK" in the file header.
  local full="#[fg=$section_bg${comma}bg=$prev_bg]${_sep_left}#[fg=$text_fg${comma}bg=$section_bg]#[push-default] $text #[pop-default]"
  local short=""
  if [[ -n "$text_short" ]]; then
    short="#[fg=$section_bg${comma}bg=$prev_bg]${_sep_left}#[fg=$text_fg${comma}bg=$section_bg]#[push-default] $text_short#[default] #[pop-default]"
  fi

  _collapse_wrap "$priority" "$full" "$short"
}

# Renders a window tab (used for both active and inactive windows).
# Window tabs have arrows on both sides and use bare commas (they
# are never inside conditionals).
#
# $1 = module name ("window" or "window_current")
_powerline_window() {
  local name="$1"
  local status_bg="$(_status_bg)"
  local fg_var="mod_${name}_fg"     ; local fg="${!fg_var}"
  local bg_var="mod_${name}_bg"     ; local section_bg_name="${!bg_var}"
  local bold_var="mod_${name}_bold" ; local bold="${!bold_var:-no}"
  local text_var="mod_${name}_text" ; local text="${!text_var}"

  local bold_attr=""
  [[ "$bold" == "yes" ]] && bold_attr=",bold"
  local text_fg="$(_resolve_color "$fg")"
  local section_bg="$(_resolve_color "$section_bg_name")"

  # Format: #[open arrow]#[text style] content #[close arrow]
  # push-default makes the section style the local default so any
  # #[default] emitted from inside $text resets to it (see file header).
  echo "#[fg=$status_bg,bg=$section_bg]${_sep_right}#[fg=$text_fg,bg=$section_bg$bold_attr]#[push-default] $text#[default] #[pop-default]#[fg=$section_bg,bg=$status_bg]${_sep_right}"
}

# }}

# ════════════════════════════════════════════════════════════════════════════
# PILL RENDERERS
# ════════════════════════════════════════════════════════════════════════════
#
# Pill sections are self-contained capsules. Each has an opening half-circle
# and a closing half-circle, rendered against the status-line background.
# No neighbor-aware chaining is needed.
#
# Format: #[open]#[text] content #[close]#[reset]
#
# The reset (#[fg=status_bg, bg=status_bg]) after the close glyph prevents
# the section's fg color from bleeding into the gap between adjacent pills.
#
# All commas inside pill styles use #, (escaped) because pill sections
# may be placed inside #{?...} conditionals by _collapse_wrap.
#
# {{

# Low-level pill capsule builder. Used by all pill renderers.
#
# $1 = text_fg:   resolved fg color for text content
# $2 = section_bg: resolved bg color for the capsule
# $3 = bold_attr:  "" or "#,bold"
# $4 = text:       content to display
# $5 = status_bg:  the status-line background color (for glyph bg and reset)
_pill_capsule() {
  local text_fg="$1" section_bg="$2" bold_attr="$3" text="$4" status_bg="$5"

  # push-default makes the section style the local default so any
  # #[default] emitted from inside $text resets to it (see file header).
  local out=""
  out+="#[fg=$section_bg#,bg=$status_bg]${_sep_pill_open}"    # open half-circle
  out+="#[fg=$text_fg#,bg=$section_bg$bold_attr]#[push-default] $text#[default] #[pop-default]"  # padded content (style-reset safe)
  out+="#[fg=$section_bg#,bg=$status_bg]${_sep_pill_close}"   # close half-circle
  out+="#[fg=$status_bg#,bg=$status_bg]"                         # reset to prevent color bleed
  echo "$out"
}

# Renders the session indicator as a pill capsule.
# Tri-state: normal / prefix-active / copy-mode (same states as powerline).
_pill_session() {
  local status_bg="$(_status_bg)"
  local text_fg="$(_resolve_color "$mod_session_fg")"
  local section_bg="$(_resolve_color "$mod_session_bg")"
  local prefix_fg="$(_resolve_color "$mod_session_prefix_fg")"
  local prefix_bg="$(_resolve_color "$mod_session_prefix_bg")"
  local copy_fg="$(_resolve_color "$mod_session_copy_fg")"
  local copy_bg="$(_resolve_color "$mod_session_copy_bg")"
  local text="$mod_session_text"

  local out=""
  out+="#{?client_prefix,"
  out+="$(_pill_capsule "$prefix_fg" "$prefix_bg" "" "$text" "$status_bg")"
  out+=",#{?pane_in_mode,"
  out+="$(_pill_capsule "$copy_fg" "$copy_bg" "" "$text" "$status_bg")"
  out+=","
  out+="$(_pill_capsule "$text_fg" "$section_bg" "" "$text" "$status_bg")"
  out+="}}"
  echo "$out"
}

# Renders a generic pill section (left or right — pills are symmetric).
# $1 = module name
_pill_section() {
  local name="$1"
  local fg_var="mod_${name}_fg"         ; local fg="${!fg_var}"
  local bg_var="mod_${name}_bg"         ; local bg="${!bg_var}"
  local bold_var="mod_${name}_bold"     ; local bold="${!bold_var:-no}"
  local text_var="mod_${name}_text"     ; local text="${!text_var}"
  local pri_var="mod_${name}_priority"  ; local priority="${!pri_var:-0}"
  local short_var="mod_${name}_text_short" ; local text_short="${!short_var}"

  local bold_attr=""
  [[ "$bold" == "yes" ]] && bold_attr="#,bold"  # must escape comma (may be inside conditional)

  local text_fg="$(_resolve_color "$fg")"
  local section_bg="$(_resolve_color "$bg")"
  local status_bg="$(_status_bg)"

  local full; full="$(_pill_capsule "$text_fg" "$section_bg" "$bold_attr" "$text" "$status_bg")"
  local short=""
  if [[ -n "$text_short" ]]; then
    short="$(_pill_capsule "$text_fg" "$section_bg" "$bold_attr" "$text_short" "$status_bg")"
  fi

  _collapse_wrap "$priority" "$full" "$short"
}

# Renders a window tab as a pill capsule.
# $1 = module name ("window" or "window_current")
_pill_window() {
  local name="$1"
  local fg_var="mod_${name}_fg"     ; local fg="${!fg_var}"
  local bg_var="mod_${name}_bg"     ; local section_bg_name="${!bg_var}"
  local bold_var="mod_${name}_bold" ; local bold="${!bold_var:-no}"
  local text_var="mod_${name}_text" ; local text="${!text_var}"

  local bold_attr=""
  [[ "$bold" == "yes" ]] && bold_attr="#,bold"

  local text_fg="$(_resolve_color "$fg")"
  local section_bg="$(_resolve_color "$section_bg_name")"
  local status_bg="$(_status_bg)"

  _pill_capsule "$text_fg" "$section_bg" "$bold_attr" "$text" "$status_bg"
}

# }}

# ════════════════════════════════════════════════════════════════════════════
# LAYOUT BUILDERS
# ════════════════════════════════════════════════════════════════════════════
#
# These functions walk the layout arrays and render each module using the
# appropriate style (powerline or pill). For powerline mode, they also
# handle separator chaining between adjacent modules.
#
# {{

# Builds the left side of the status line.
# Iterates layout_left and renders each module.
#
# For powerline mode, each section needs to know the bg color of the
# NEXT section (for the closing arrow's background). If the next module
# is collapsible (priority > 0), we use the status-line bg instead
# (since the next module might be hidden).
_build_left() {
  local status_bg="$(_status_bg)"
  local modules=("$@")
  local result="" count=${#modules[@]}

  for ((i=0; i<count; i++)); do
    local name="${modules[$i]}"
    local style; style="$(_get_module_style "$name")"

    if [[ "$name" == "session" ]]; then
      # Session is special — has tri-state coloring
      if [[ "$style" == "pill" ]]; then
        result+="$(_pill_session)"
      else
        # For powerline, determine what's to the RIGHT of session
        local next_bg="$status_bg"
        if ((i + 1 < count)); then
          local next_name="${modules[$((i+1))]}"
          local next_bg_var="mod_${next_name}_bg"
          local next_bg_color="${!next_bg_var}"
          if [[ -n "$next_bg_color" ]]; then
            local next_pri_var="mod_${next_name}_priority"
            # Only use neighbor's bg if it's always-visible (pri=0)
            if [[ "${!next_pri_var:-0}" == "0" ]]; then
              next_bg="$(_resolve_color "$next_bg_color")"
            fi
          fi
        fi
        result+="$(_powerline_session "$next_bg")"
      fi
    else
      if [[ "$style" == "pill" ]]; then
        result+="$(_pill_section "$name")"
      else
        local next_bg="$status_bg"
        if ((i + 1 < count)); then
          local next_name="${modules[$((i+1))]}"
          local next_bg_var="mod_${next_name}_bg"
          local next_bg_color="${!next_bg_var}"
          if [[ -n "$next_bg_color" ]]; then
            local next_pri_var="mod_${next_name}_priority"
            if [[ "${!next_pri_var:-0}" == "0" ]]; then
              next_bg="$(_resolve_color "$next_bg_color")"
            fi
          fi
        fi
        result+="$(_powerline_left "$name" "$next_bg")"
      fi
    fi
  done
  echo "$result"
}

# Builds the right side of the status line.
# Iterates layout_right and renders each module.
#
# For powerline mode, each section needs to know the bg color of the
# PREVIOUS section (for the opening arrow's background). When the
# previous module is collapsible and has a different priority, the
# arrow bg depends on whether that module is visible. We handle this
# by rendering the section TWICE (once with neighbor bg, once with
# status bg) and wrapping both in a tmux conditional.
#
# NOTE: We cannot embed #{?...} conditionals inside #[bg=...] style
# attributes — tmux doesn't evaluate them there. Instead, we duplicate
# the entire section string for each case and let tmux choose between
# them with a top-level conditional.
_build_right() {
  local status_bg="$(_status_bg)"
  local modules=("$@")
  local result="" count=${#modules[@]}

  for ((i=0; i<count; i++)); do
    local name="${modules[$i]}"

    # Raw modules inject their text directly (e.g. pomodoro)
    local raw_var="mod_${name}_raw"
    if [[ "${!raw_var}" == "yes" ]]; then
      local text_var="mod_${name}_text"
      result+="${!text_var}"
      continue
    fi

    local style; style="$(_get_module_style "$name")"

    if [[ "$style" == "pill" ]]; then
      # Pill sections are self-contained — no neighbor awareness needed
      result+="$(_pill_section "$name")"
    else
      # Powerline: find the bg of the section to our LEFT
      local current_priority_var="mod_${name}_priority"
      local current_priority="${!current_priority_var:-0}"
      local adaptive_section=""  # set if we need a conditional separator

      local prev_bg="$status_bg"
      for ((j=i-1; j>=0; j--)); do
        local prev_name="${modules[$j]}"
        local prev_raw_var="mod_${prev_name}_raw"
        [[ "${!prev_raw_var}" == "yes" ]] && continue  # skip raw modules
        local prev_style; prev_style="$(_get_module_style "$prev_name")"
        [[ "$prev_style" == "pill" ]] && continue  # pills don't chain

        local prev_bg_var="mod_${prev_name}_bg"
        local prev_bg_color="${!prev_bg_var}"
        local prev_pri_var="mod_${prev_name}_priority"
        local prev_priority="${!prev_pri_var:-0}"

        if [[ -n "$prev_bg_color" ]]; then
          if [[ "$prev_priority" -gt 0 && "$prev_priority" != "$current_priority" ]]; then
            # The neighbor is collapsible and has different priority —
            # it might be hidden. Render two versions of this section:
            #   when_visible: arrow bg = neighbor's bg
            #   when_hidden:  arrow bg = status line bg
            # Wrap both in a conditional. Both use escape_comma=yes
            # because they'll be inside #{?...}.
            local prev_threshold; prev_threshold="$(_priority_threshold "$prev_priority")"
            local prev_resolved_bg="$(_resolve_color "$prev_bg_color")"
            local when_visible; when_visible="$(_powerline_right "$name" "$prev_resolved_bg" yes)"
            local when_hidden; when_hidden="$(_powerline_right "$name" "$status_bg" yes)"
            adaptive_section="#{?#{e|>=:#{window_width},${prev_threshold}},$when_visible,$when_hidden}"
          else
            # Neighbor is always-visible or same priority — static bg
            prev_bg="$(_resolve_color "$prev_bg_color")"
          fi
          break
        fi
      done

      if [[ -n "$adaptive_section" ]]; then
        result+="$adaptive_section"
      else
        # Determine comma escaping: collapsible modules (pri > 0) will be
        # wrapped in a conditional by _collapse_wrap, so need escaped commas.
        # Always-visible modules (pri = 0) are bare — use normal commas.
        local escape="no"
        [[ "$current_priority" != "0" ]] && escape="yes"
        result+="$(_powerline_right "$name" "$prev_bg" "$escape")"
      fi
    fi
  done
  echo "$result"
}

# Renders window tabs (centre section of the status line).
# Checks the window module's style to choose powerline or pill.
_build_windows() {
  local style; style="$(_get_module_style "window")"
  if [[ "$style" == "pill" ]]; then
    tmux set-option -g window-status-format "$(_pill_window window)"
    tmux set-option -g window-status-current-format "$(_pill_window window_current)"
  else
    tmux set-option -g window-status-format "$(_powerline_window window)"
    tmux set-option -g window-status-current-format "$(_powerline_window window_current)"
  fi
}

# }}

# ════════════════════════════════════════════════════════════════════════════
# PUBLIC ENTRY POINT
# ════════════════════════════════════════════════════════════════════════════
# {{

# Call this after defining all modules and layout arrays.
# It computes thresholds, renders all sections, and applies them to tmux.
status_engine_apply() {
  # Step 1: Auto-compute collapse thresholds from module widths
  _compute_thresholds "both" "${layout_left[@]}" "${layout_right[@]}"

  # Step 2: Set global tmux options
  tmux set-option -g status-justify "absolute-centre"
  tmux set-option -g window-status-separator ""

  # Step 3: Render and apply all sections
  _build_windows

  tmux set-option -g status-left-length 200
  tmux set-option -g status-left "$(_build_left "${layout_left[@]}")"

  tmux set-option -g status-right-length 300
  tmux set-option -g status-right "$(_build_right "${layout_right[@]}") "
}

# }}
