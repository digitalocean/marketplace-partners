#!/bin/bash
set -e

export GOPATH=/usr/local/go/bin
export PATH=$GOPATH:/usr/local/go/bin:$PATH

# bash /root/start_node.sh "15.0.0" "https://github.com/osmosis-labs/osmosis/raw/main/networks/osmosis-1/genesis.json" "https://snapshots.osmosis.zone/v15/latest.json" "https://snapshots.polkachu.com/addrbook/osmosis/addrbook.json" "mainnet"

MONIKER=osmosis
OSMOSIS_HOME=/root/.osmosisd
OSMOSIS_VERSION=$1
GENESIS_URL=$2
SNAPSHOT_URL=$(curl -s $3)
ADDRBOOK_URL=$4

# Download the binary
sudo wget -q https://github.com/osmosis-labs/osmosis/releases/download/v$OSMOSIS_VERSION/osmosisd-$OSMOSIS_VERSION-linux-amd64 -O /usr/local/bin/osmosisd
sudo chmod +x /usr/local/bin/osmosisd

# Brutal cleaning of home
if [ -d "$OSMOSIS_HOME" ]; then
    # Start clean
    # Brutal but it avoids some edge cases
    rm -rf $OSMOSIS_HOME
fi

# Initialize osmosis home
osmosisd init $MONIKER

if [ "$5" == "testnet" ]; then
  cp $HOME/client-testnet.toml $HOME/.osmosisd/config/client.toml
  cp $HOME/config-testnet.toml $HOME/.osmosisd/config/config.toml
  cp $HOME/app-testnet.toml $HOME/.osmosisd/config/app.toml
fi

if [ "$5" == "mainnet" ]; then
  cp $HOME/client.toml $HOME/.osmosisd/config/client.toml
  cp $HOME/config.toml $HOME/.osmosisd/config/config.toml
  cp $HOME/app.toml $HOME/.osmosisd/config/app.toml
fi

# Download genesis
wget -q $GENESIS_URL -O $OSMOSIS_HOME/config/genesis.json

# Download addrbook
wget -q $ADDRBOOK_URL -O $OSMOSIS_HOME/config/addrbook.json

# Download the snapshot
wget -q -O - $SNAPSHOT_URL | lz4 -d | tar -C $OSMOSIS_HOME/ -xvf -

nohup osmosisd start --home ${OSMOSIS_HOME} --x-crisis-skip-assert-invariants &
