#!/bin/sh

# DigitalOcean Marketplace Image Validation Tool
# © 2021 DigitalOcean LLC.
# This code is licensed under Apache 2.0 license (see LICENSE.md for details)

wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.17.2
# source /root/.bashrc
# source ~/.profile
git clone https://github.com/osmosis-labs/osmosis
cd osmosis
git checkout $application_version
make install
echo '$HOME/startup.sh' >> ~/.bashrc
cd $HOME
chmod +x $HOME/99-one-click-osmosis
chmod +x $HOME/startup.sh
mv $HOME/99-one-click-osmosis /etc/update-motd.d/