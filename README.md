# Marketplace partner tools

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Image validation, automation, and other tools for DigitalOcean Marketplace partners and Custom Image users.

![Screenshot](screenshot.png)

This repository includes bash scripts intended for use by Marketplace partners and Custom Image users to validate their images prior to submission, or use.

##Build an Image Manually

If you're just getting started, [this](marketplace_docs/build-an-image.md) is where to begin.

## Build an Image with Fabric automation

For repeatable image build processing, [this](marketplace_docs/build-an-image-fabric.md) is a good next step.

## marketplace_validation

Provides a script `img_check.sh` that validates your build Droplet before shutting down to create a snapshot image for submission.

### Supported Distributions 

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

The script img_check.sh can be used from within the image build system prior to creating a snapshot or exporting a disk image from Virtualbox, VMWare or a physical machine. The script is minimally invasive and designed to avoid changes to the disk. The one exception is that this script will update your apt or yum package database in order to identify if there are any uninstalled security updates.

To clear log files, bash_history, and authorized keys, you can use any file clearing method, including truncate against each result the script outputs, e.g.,

`$ truncate --size 0 <path/to/file.log>`

## byoi_validation

### Supported Distributions 

* Ubuntu 18.04 (LTS)
* Ubuntu 16.04 (LTS)
* CentOS 7.x
* CentOS 6.x 

*(may be expanded to support other popular distributions in future versions)*

This is a fork of the marketplace_validation script and is intended for use by users of DigitalOcean Custom Images to use with their own images.

The script img_check.sh can be run on the system used to create a Custom Image (for upload and use in the DigitalOcean platform) such as from within VirtualBox or QEMU. This script will update the apt or yum database on the system when it is run in order to check for security updates.

*coming soon* - This version of the script will be intended for Custom Image users who wish to check their image before upload. The primary differences will be in reporting and what levels (pass, warn, fail) are applied to different checks as they apply in a Custom Image environment.
