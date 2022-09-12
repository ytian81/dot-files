#!/bin/bash

cd /tmp

echo "install package for Tmux..."
sudo apt update
sudo apt install -y libevent-dev
sudo apt install -y ncurses-dev

echo "installTmux.sh ...."
git clone https://github.com/tmux/tmux.git
cd tmux
git checkout 3.3
sh autogen.sh
./configure && make
sudo make install

echo "$0 done."
exit 0
