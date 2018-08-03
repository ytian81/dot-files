#!/bin/bash
# instGlobal.sh

cd /tmp


echo "installPowerline.sh ...."
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh

echo "................................................................................"
echo "..........   Remeber loading powline font in the terminal profile .............."
echo "................................................................................"

echo "$0 done."
exit 0
