echo ${powerline_dir}
echo $(pwd)

ln -sf $(pwd)/config_files/colors.json ${powerline_dir}/config_files/colors.json
ln -sf $(pwd)/config_files/config.json ${powerline_dir}/config_files/config.json
ln -sf $(pwd)/config_files/themes/tmux/default_git.json ${powerline_dir}/config_files/themes/tmux/default_git.json
ln -sf $(pwd)/config_files/colorschemes/tmux/gruvbox.json ${powerline_dir}/config_files/colorschemes/tmux/gruvbox.json
ln -sf $(pwd)/config_files/colorschemes/gruvbox.json ${powerline_dir}/config_files/colorschemes/gruvbox.json
