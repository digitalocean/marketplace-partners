# Marketplace Partner Tools

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Image validation, automation, and other tools for DigitalOcean Marketplace partners and Custom Image users.

![Screenshot](screenshot.png)

This repository includes bash scripts intended for use by Marketplace partners and Custom Image users to validate their images prior to submission, or use.

## Build an Image Manually

If you're just getting started, [build-an-image.md](marketplace_docs/build-an-image.md) is where to begin. Some things here are required in your Fabric automation.

## Build an Image with Fabric Automation

For repeatable image build processing, [build-an-image-fabric.md](marketplace_docs/build-an-image-fabric.md) is a good next step.

## marketplace_validation

Provides a script `img_check.sh` that validates your build Droplet before shutting down to [create a snapshot](https://www.digitalocean.com/docs/images/snapshots/how-to/snapshot-droplets/).

### Supported Distributions 

* Debian 9.x (stretch)
* Ubuntu 18.04 (LTS)
* Ubuntu 16.04 (LTS)
* CentOS 7.x
* CentOS 6.x 

This script checks build Droplet images against the following criteria:

- Check for a supported distro and release
- Check that all security updates are installed
- Check for a populated bash_history file
- Check for ssh_keys in the image
- Check for pre-set passwords
- Check that packages are updated
- Check that a firewall is installed/configured
- Check that a valid version of cloud-init is installed
- Check for any populated log files or log archives

*coming soon* - Allow the script to be run against a disk image file on a Linux workstation by mounting and chrooting into the image.

The script img_check.sh can be used from within the image build system prior to [creating a snapshot](https://www.digitalocean.com/docs/images/snapshots/how-to/snapshot-droplets/) or exporting a disk image from Virtualbox, VMWare or a physical machine. The script is minimally invasive and designed to avoid changes to the disk. The one exception is that this script will update your apt or yum package database in order to identify if there are any uninstalled security updates.

To clear log files, bash_history, and authorized keys, you can use any file clearing method, including truncate against each result the script outputs, e.g.,

`$ truncate --size 0 <path/to/file.log>`
