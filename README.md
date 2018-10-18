# Marketplace Partners

Image validation scripts for DigitalOcean Marketplace partners and BYOI users

![Screenshot](https://github.internal.digitalocean.com/digitalocean/marketplace_scripts/blob/master/screenshot.png?raw=true)

This repository includes bash scripts intended for use by Marketplace partners and BYOI users to validate their images prior to submission or use.


**marketplace_validation**

Supported Distributions: CentOS 6.x, CentOS 7.x, Ubuntu 16.04, Ubuntu 18.04

Intended for Marketplace Partners to check their images for the following criteria:

- Check for a supported distro and release
- Check that all security updates are installed
- Check for a populated bash_history file
- Check for ssh_keys in the image
- Check for pre-set passwords
- Check that packages are updated
- Check that a firewall is installed/configured
- Check that a valid version of cloud-init is installed
- Check for any populated log files or log archives
- (to do) Allow the script to be run against a disk image file on a Linux workstation by mounting and chrooting into the image

The script img_check.sh can be used from within the image build system prior to creating a snapshot or exporting a disk image from Virtualbox, VMWare or a phycial machine.
This script is minimally invasive and designed to avoid changes to the disk.  The one exception is that this script will update your apt or yum package database in order
to identify if there are any uninstalled security updates.

**byoi_validation**

Initial fork of the marketplace script.  This script is intended for use by users of DigitalOcean BYOI to use their own images.

Supported distributions:  CentOS 6.x, CentOS 7.x, Ubuntu 16.04, Ubuntu 18.04 (will be expanded to support other popular distributions in recent versions)

The script img_check.sh can be run on the system used to create an image for BYOI such as from within VirtualBox or QEMU.  This script will update the apt or yum database on the system when it is run in order to check for security updates.

*coming soon* - This version of the script will be intended for BYOI users who wish to check their image before upload.  The primary differences will be in reporting and what
levels (pass,warn,fail) are applied to different checks as they apply in a BYOI environment.


