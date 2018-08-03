#!/bin/bash

# install applications


# link configuration file
current_directory=`pwd`
dot_files=$(find $current_directory -type f -name '.*rc' -o -name '.*config')
# echo $dot_files

for dot_file in $dot_files; do
  file_name=$(basename $dot_file)
  echo "linking" $file_name
  ln -s $dot_file $HOME/$file_name
done
