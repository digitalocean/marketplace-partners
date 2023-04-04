#!/bin/sh

export GO_VERSION=1.19.7
apt-get update
apt-get install -y wget git gcc
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
export PATH=/usr/local/go/bin:$PATH
echo "export PATH=/usr/local/go/bin:$PATH" >> /root/.bashrc
go version
git clone https://github.com/osmosis-labs/osmosis
cd osmosis/
git checkout $application_version
make install
/root/go/bin/osmosisd version
cp /root/go/bin/osmosisd /usr/bin/osmosisd
chmod a+x /usr/bin/osmosisd
osmosisd version

echo '$HOME/startup.sh' >> ~/.bashrc
cd $HOME
chmod +x $HOME/99-one-click-osmosis
chmod +x $HOME/startup.sh
mv $HOME/99-one-click-osmosis /etc/update-motd.d/