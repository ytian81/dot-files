FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y install curl
Run curl -sL https://deb.nodesource.com/setup_18.x | bash

RUN apt-get update
RUN apt-get -y install git
RUN apt-get -y install zsh
RUN apt-get -y install python3 python3-pip
RUN apt-get -y install nodejs

RUN apt-get -y install neovim
RUN apt-get -y install tmux
# # build neovim from source
# RUN apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
# RUN git clone https://github.com/neovim/neovim /root/Documents
# RUN cd /root/Documents/neovim && git checkout stable && make -j4 && make install

# copy all files into docker image
ENV DOT_FILES_PATH=/root/Documents/Configurations/dot-files
RUN mkdir -p $DOT_FILES_PATH
COPY . $DOT_FILES_PATH

# install required application
RUN zsh $DOT_FILES_PATH/install/linux/install.sh

# setup
RUN zsh $DOT_FILES_PATH/install/common/install.sh

RUN chsh -s /bin/zsh
ENV SHELL=zsh

# workspace
RUN mkdir -p /root/workspace
WORKDIR /root/workspace
