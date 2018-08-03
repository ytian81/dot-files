#!/bin/bash
# instGlobal.sh

cd /tmp

echo "installRg.sh ...."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.8.1/ripgrep_0.8.1_amd64.deb
sudo dpkg -i ripgrep_0.8.1_amd64.deb

echo "$0 done."
exit 0
