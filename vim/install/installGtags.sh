#!/bin/bash
# instGlobal.sh

cd /tmp

echo "installGlobal.sh ...."

echo "install package for GNU global..."
sudo apt-get update
sudo apt-get -y install curl
sudo apt-get -y install wget
sudo apt-get -y install ncurses-dev

echo "install GNU global..."
wget http://tamacom.com/global/global-6.6.3.tar.gz
tar zxvf global-6.6.3.tar.gz
cd global-6.6.3
./configure
make
sudo make install

echo "install pygments..."
sudo apt-get -y install python python-pip
sudo pip install pygments

echo "universal-ctags..."
curl -L https://github.com/thombashi/universal-ctags-installer/raw/master/universal_ctags_installer.sh | sudo bash


echo "$0 done."
exit 0
