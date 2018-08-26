.PHONY:
	link
	clean
	oh-my-zsh
	link-vimrc
	link-zshrc
	link-tmuxconf
	zsh-completions
	zsh-autosuggestions
	zsh-syntax-highlighting
	dircolors
	youcompleteme

link:
	@echo "Installing of all dot files"
	make link-vimrc
	make link-zshrc
	make link-tmuxconf

clean:
	@echo "Cleaning all dot files"
	rm ~/.vimrc
	rm ~/.zshrc
	rm ~/.tmux.conf

link-vimrc:
	ln -sf `pwd`/.vimrc ~/.vimrc
link-zshrc:
	ln -sf `pwd`/.zshrc ~/.zshrc
link-tmuxconf:
	ln -sf `pwd`/.tmux.conf ~/.tmux.conf

oh-my-zsh:
	@echo "Installing oh-my-zsh"
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash

zsh-completions:
	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh-syntax-highlighting:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
dircolors:
	curl https://raw.githubusercontent.com/coreutils/coreutils/master/src/dircolors.hin -o ~/.dircolors
