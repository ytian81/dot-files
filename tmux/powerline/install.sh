powerline_repository_root=/home/ytian/.local/lib/python2.7/site-packages/powerline

echo ${powerline_repository_root}
echo ${PWD}

ln -sf ${PWD}/config_files/colors.json ${powerline_repository_root}/config_files/colors.json
ln -sf ${PWD}/config_files/config.json ${powerline_repository_root}/config_files/config.json
ln -sf ${PWD}/config_files/themes/tmux/default_git.json ${powerline_repository_root}/config_files/themes/tmux/default_git.json
ln -sf ${PWD}/config_files/colorschemes/tmux/gruvbox.json ${powerline_repository_root}/config_files/colorschemes/tmux/gruvbox.json
ln -sf ${PWD}/config_files/colorschemes/gruvbox.json ${powerline_repository_root}/config_files/colorschemes/gruvbox.json
