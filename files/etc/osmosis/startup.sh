#!/bin/bash

rm -f startup.sh
sed -i "/^.*startup.*$/d" ~/.bashrc
#osmosisd init osmoDroplet -o > /dev/null 2>&1
#rm -r $HOME/.osmosisd
osmosisd unsafe-reset-all > /dev/null 2>&1
osmosisd init osmoDroplet -o > /dev/null 2>&1
mv $HOME/client.toml $HOME/.osmosisd/config/