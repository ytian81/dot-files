.PHONY:
	link
	link-vimrc
	link-initvim
	link-coc-settings
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
	bat-syntax
	ctags
	ranger
	ranger-rc-conf
	ranger-plugins-devicon2
	ranger-colorschemes-gruvbox
	clean

link:
	@echo "Installing of all dot files"
	make link-vimrc
	make link-zshrc
	make link-tmuxconf
link-vimrc:
	ln -sf `pwd`/.vimrc ~/.vimrc
link-initvim:
	ln -sf `pwd`/vim/init.vim ~/.config/nvim/init.vim
link-coc-settings:
	ln -sf `pwd`/vim/coc-settings.json ~/.config/nvim/coc-settings.json
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
	make fast-syntax-highlighting
	make fzf-tab
	make forgit
	make you-should-use
	make autoupdate
zsh-completions:
	git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fast-syntax-highlighting:
	git clone https://github.com/zdharma/fast-syntax-highlighting ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
fzf-tab:
	git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab
forgit:
	git clone https://github.com/wfxr/forgit ~/.oh-my-zsh/custom/plugins/forgit
you-should-use:
	git clone https://github.com/MichaelAquilina/zsh-you-should-use ~/.oh-my-zsh/custom/plugins/you-should-use
autoupdate:
	git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ~/.oh-my-zsh/custom/plugins/autoupdate

dircolors:
	curl -fsSL https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-dark -o ~/.dircolors
fzf-extras:
	git clone https://github.com/atweiden/fzf-extras.git ~/.fzf-extras

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

ctags:
	ln -sf `pwd`/.ctags.d ~/.ctags.d
bat-syntax:
	mkdir -p ~/.config/bat/syntaxes
	git clone https://github.com/facelessuser/sublime-languages ~/.config/bat/syntaxes
	bat cache --build
ranger:
	make ranger-rc-conf
	make ranger-plugins-devicon2
	make ranger-colorschemes-gruvbox
ranger-rc-conf:
	ln -sf `pwd`/ranger/rc.conf ~/.config/ranger/rc.conf
ranger-plugins-devicon2:
	git clone https://github.com/cdump/ranger-devicons2 ~/.config/ranger/plugins/devicons2
ranger-colorschemes-gruvbox:
	mkdir -p ~/.config/ranger/colorschemes
	ln -sf `pwd`/ranger/colorschemes/gruvbox.py ~/.config/ranger/colorschemes/gruvbox.py
bazel-zsh-autocomplete:
	mkdir -p ~/.zsh/completion
	mkdir -p ~/.zsh/cache
	wget https://raw.githubusercontent.com/bazelbuild/bazel/master/scripts/zsh_completion/_bazel --output-document ~/.zsh/completion/_bazel
	rm -f ~/.zcompdump; compinit

clean:
	@echo "Cleaning all dot files"
	rm ~/.vimrc
	rm ~/.zshrc
	rm ~/.tmux.conf
