# DigitalOcean Marketplace Partner Tools

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Image validation, automation, and other tools for [DigitalOcean Marketplace](https://marketplace.digitalocean.com/) partners.

![A screenshot of the terminal output for the Marketplace Image Validation Tool](example-output.png)

## Getting Started

This is our recommended process for building a Marketplace image:

1. **Create and configure a build Droplet manually first** to make sure your configuration works.
2. **Clean up and validate the build Droplet with the provided scripts**, `cleanup.sh` and `img_check.sh`. The scripts will check for and fix potential security concerns and verify that the image will be compatible with Marketplace.
3. **Take a [snapshot](https://www.digitalocean.com/docs/images/snapshots/) of the build Droplet** after you power it down, then test the resulting image. While there are several ways to create an image, we recommend snapshots as the most simple and consistent option.
4. **Automate your build** to ensure replicable and configurable builds. We provide some Fabric and Packer templates to get you started.
5. **Submit your final image** to the Marketplace team for review.

We have [detailed documentation on building images](marketplace_docs/getting-started.md) that includes more specific image recommendations, tips on how to run commands on first boot and first login, and details on exactly what our helper scripts do. We also have a [Fabric template and docs](marketplace_docs/templates/Fabric/README.md) and a [Packer template and docs](marketplace_docs/templates/Packer/README.md) that you can use as starting points to automate your build system.

## Supported Operating Systems

To ensure compatibility with Marketplace tools and processes, we only support a limited number of Linux distributions and releases for Marketplace images. These options provide either `deb`- or `rpm`-based packaging and will have security patches and updates for a reasonable time period.

We currently support the following operating systems:

- Debian 9 (stretch)
- Ubuntu 18.04 (LTS)
- Ubuntu 16.04 (LTS)
- CentOS 7.x
- CentOS 6.x

All supported operating systems are available as base images to build on in the DigitalOcean cloud.

## Software Prerequisites

The following software packages are necessary for the initial configuration of new Droplets and to ensure connectivity:

- `cloud-init` 0.76 or higher (0.79 or higher recommended)
- `openssh-server` (SFTP enabled configuration recommended)

All of these packages are provided by default in the default DigitalOcean base images.
