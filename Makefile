.PHONY:
	link
	link-vimrc
	link-zshrc
	link-tmuxconf
	oh-my-zsh
	zsh-plugins
	zsh-completions
	zsh-autosuggestions
	zsh-syntax-highlighting
	fzf-extras
	dircolors
	powerline-status
	powerline-config
	youcompleteme
	clean

link:
	@echo "Installing of all dot files"
	make link-vimrc
	make link-zshrc
	make link-tmuxconf
link-vimrc:
	ln -sf `pwd`/.vimrc ~/.vimrc
link-zshrc:
	ln -sf `pwd`/.zshrc ~/.zshrc
link-tmuxconf:
	ln -sf `pwd`/.tmux.conf ~/.tmux.conf

oh-my-zsh:
	@echo "Installing oh-my-zsh"
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash

zsh-plugins:
	@echo "Install oh-my-zsh and plugins"
	make zsh-completions
	make zsh-autosuggestions
	make zsh-syntax-highlighting
	make dircolors
zsh-completions:
	git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
zsh-syntax-highlighting:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fzf-extras:
	git clone https://github.com/atweiden/fzf-extras.git ~/.fzf-extras
dircolors:
	curl -fsSL https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark -o ~/.dircolors

powerline-status:
	pip install powerline-status 2>/dev/null
powerline-config:
	ln -sf `pwd`/tmux/powerline/config_files/colors.json "${powerline_dir}/config_files/colors.json"
	ln -sf `pwd`/tmux/powerline/config_files/config.json "${powerline_dir}/config_files/config.json"
	ln -sf `pwd`/tmux/powerline/config_files/themes/tmux/default_git.json "${powerline_dir}/config_files/themes/tmux/default_git.json"
	ln -sf `pwd`/tmux/powerline/config_files/colorschemes/tmux/gruvbox.json "${powerline_dir}/config_files/colorschemes/tmux/gruvbox.json"
	ln -sf `pwd`/tmux/powerline/config_files/colorschemes/gruvbox.json "${powerline_dir}/config_files/colorschemes/gruvbox.json"

youcompleteme:
	cd ~/.vim/plugged/YouCompleteMe; ./install.py --clang-completer

clean:
	@echo "Cleaning all dot files"
	rm ~/.vimrc
	rm ~/.zshrc
	rm ~/.tmux.conf
