#!/bin/sh

# DigitalOcean Marketplace Image Validation Tool
# © 2021 DigitalOcean LLC.
# This code is licensed under Apache 2.0 license (see LICENSE.md for details)

sudo ufw allow 1317,26656,26660,22,80,443/tcp
sudo ufw --force enable