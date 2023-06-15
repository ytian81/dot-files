# INTRODUCTION

Modularized dot-files

# TODO

[ ] True color support

[ ] miniconda python

[ ] pytorch

# Linux Setup

* [i3-gaps](https://github.com/Airblader/i3)

* [betterlockscreen](https://github.com/pavanjadhaw/betterlockscreen)

* [dunst](https://github.com/dunst-project/dunst)

* [polybar](https://github.com/polybar/polybar)

* [interception](https://gitlab.com/interception/linux/tools)
 * [caps2esc](https://gitlab.com/interception/linux/plugins/caps2esc)
 * [space2meta](https://gitlab.com/interception/linux/plugins/space2meta)

* [tmux](https://medium.com/@alexeysamoshkin/tmux-in-practice-series-of-posts-ae34f16cfab0)

# Mac Setup

* iTerm2
 * Preferences -> Profiles -> Text
   * Use built-in Powerline glyphs
   * Font 
     Source Code Pro for Powerline, Regular 12
   * Non-ASCII Font
     MesloLGS NF, Regular 12, Meslo Nerd Font

* Karabiner
 * [Change caps_lock key](https://ke-complex-modifications.pqrs.org/#caps_lock) 
   Change caps_lock to control if pressed with other keys, to escape if pressed alone.
 * [Ctrl + Arrow keys/Backspace](https://ke-complex-modifications.pqrs.org/#windows_like_word_bindings)
   Word wise movement
 * [Lock screen](https://ke-complex-modifications.pqrs.org/#lock_screen) 
   Option + L to lock screen

* [Alt-Tab](https://github.com/lwouis/alt-tab-macos)

* [Rectangle](https://github.com/rxhanson/Rectangle)

* [tmux](https://medium.com/@alexeysamoshkin/tmux-in-practice-series-of-posts-ae34f16cfab0)

# Docker

Build an image
```
docker image build -t ytian/ide .
```

Run the container
```
docker container run -v /path/to/host:/root/workspace -it ytian/ide zsh
```
