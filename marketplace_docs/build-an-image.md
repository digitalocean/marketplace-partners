# How to build an image for One-click apps on DigitalOcean

In order to submit an image to an app listing for DigitalOcean Marketplace, you must engineer it in 
a compatible format, using a supported operating system and with a few necessary pre-requisities, and 
then pass the tests in the marketplace_validation _img check.sh_ script. 

## Supported operating systems and pre-requisities

### Operating systems

* Ubuntu 18.04
* Ubuntu 16.04
* CentOS 7.x
* CentOS 6.x

### Pre-requisites

* cloud-init 0.76 or higher _(0.79 or higher recommended)_

## Building an image

There are two methods to engineer an image:

1. Snapshot - build on a supported DigitalOcean base image
2. Custom Image - build on a supported upstream base, and upload to DigitalOcean

_n.b. While you can engineer a Custom Image and upload it to DigitalOcean for Marketplace apps,
users of Droplets started from those images currently have certain features restricted (floating IPs, 
IPv6). **We therefore recommend using the Snapshot method until further notice.**_

### Snapshot

