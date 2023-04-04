#!/bin/bash

rm -f startup.sh
sed -i "/^.*startup.*$/d" ~/.bashrc
