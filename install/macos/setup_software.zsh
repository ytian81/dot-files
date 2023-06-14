#!/usr/bin/env zsh

# set up iTerm2
function setup_iterm2_general() {
  local -r settings=(
    '"AllowClipboardAccess"'                        bool   1
  )

  print -nP -- "Changing %BiTerm2%b general ..."
  local k t v
  for k t v in $settings; do
    /usr/libexec/PlistBuddy -c "Set :$k $v" \
      ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null && continue
    /usr/libexec/PlistBuddy -c "Add :$k $t $v" ~/Library/Preferences/com.googlecode.iterm2.plist
  done
  print -nP " %2FOK%f"
  print -P ""
}
function setup_iterm2_appearance() {
  local -r settings=(
    '"TabStyleWithAutomaticOption"'                 real   5
    '"HideScrollbar"'                               bool   1
  )

  print -nP -- "Changing %BiTerm2%b appearance ..."
  local k t v
  for k t v in $settings; do
    /usr/libexec/PlistBuddy -c "Set :$k $v" \
      ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null && continue
    /usr/libexec/PlistBuddy -c "Add :$k $t $v" ~/Library/Preferences/com.googlecode.iterm2.plist
  done
  print -nP " %2FOK%f"
  print -P ""
}
function setup_iterm2_profile() {
  local -r font_size=12
  local -r settings=(
    '"Normal Font"'                                 string '"SourceCodeProRoman-Regular '$font_size'"'
    '"Terminal Type"'                               string '"xterm-256color"'
    '"Horizontal Spacing"'                          real   1
    '"Vertical Spacing"'                            real   1
    '"Minimum Contrast"'                            real   0
    '"Use Bold Font"'                               bool   1
    '"Use Bright Bold"'                             bool   1
    '"Use Italic Font"'                             bool   1
    '"ASCII Anti Aliased"'                          bool   1
    '"Non-ASCII Anti Aliased"'                      bool   1
    '"Use Non-ASCII Font"'                          bool   1
    '"Non Ascii Font"'                              string '"MesloLGS-NF-Regular '$font_size'"'
    '"Ambiguous Double Width"'                      bool   0
    '"Draw Powerline Glyphs"'                       bool   1
    '"Only The Default BG Color Uses Transparency"' bool   1
  )

  print -nP -- "Changing %BiTerm2%b profile ..."
  local k t v
  for k t v in $settings; do
    /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:$k $v" \
      ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null && continue
    /usr/libexec/PlistBuddy -c \
      "Add :\"New Bookmarks\":0:$k $t $v" ~/Library/Preferences/com.googlecode.iterm2.plist
  done
  print -nP " %2FOK%f"
  print -P ""
}
function setup_iterm2_color() {
  print -nP -- "Installing %BiTerm2%b preset color Gruvbox Dark ..."
  pushd /tmp
  git clone --depth=1 https://github.com/mbadolato/iTerm2-Color-Schemes 2>/dev/null 1>&2
  cd iTerm2-Color-Schemes
  tools/import-scheme.sh -v 'GruvboxDark' 2>/dev/null 1>&2
  popd
  print -nP " %2FOK%f"
  print -P ""

  print -nP -- "Changing %BiTerm2%b profile ..."
  # This doesn't persist after restart of iTerm2
  # echo -e "\033]1337;SetColors=preset=Gruvbox Dark\a"
  /usr/libexec/PlistBuddy -x -c "Print :\"Custom Color Presets\":\"GruvboxDark\"" ~/Library/Preferences/com.googlecode.iterm2.plist > /tmp/gruvbox.plist
  /usr/libexec/PlistBuddy -x -c "Print :\"New Bookmarks\":0" ~/Library/Preferences/com.googlecode.iterm2.plist > /tmp/new_bookmarks.plist
  # Merge will skip duplicate entries, so we first delete "New Bookmarks", set color and merge back
  # "New Bookmarks"
  /usr/libexec/PlistBuddy -x -c "Delete :\"New Bookmarks\":0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -x -c "Add :\"New Bookmarks\":0 Dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -x -c "Merge /tmp/gruvbox.plist :\"New Bookmarks\":0" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null
  /usr/libexec/PlistBuddy -x -c "Merge /tmp/new_bookmarks.plist :\"New Bookmarks\":0" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null 1>&2
  print -nP " %2FOK%f"
  print -P ""
}
function setup_iterm2 {
  setup_iterm2_general
  setup_iterm2_appearance
  setup_iterm2_profile
  setup_iterm2_color

  print -P "Please %Brestart iTerm2%b for the changes to take effect."
}
# setup_iterm2

# set up karabiner-elements
function setup_karabiner(){
  mkdir -p $HOME/.config/karabiner
  # ln karabiner.json
}
# setup_karabiner
