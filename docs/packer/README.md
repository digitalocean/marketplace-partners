# DigitalOcean Marketplace Image Packer Example

This repository ports the example provided in [digitalocean/marketplace-partners](https://github.com/digitalocean/marketplace-partners)
from using Fabric.py to [HashiCorp's Packer](https://www.packer.io/). This
utilizes Packer's [DigitalOcean Builder](https://www.packer.io/docs/builders/digitalocean.html)
to provide further automation. By integrating with the DigitalOcean API, the
initial Droplet creation, provisioning, and snapshoting can be done with a
single command:

    packer build marketplace-image.json

A DigitalOcean API token should be set using the `DIGITALOCEAN_TOKEN`
environment variable. This can be overridden at run time if necessary:

    packer build -var 'token=asecrectandsecureapitoken' marketplace-image.json

The APT packages to be installed are configured using the `apt_packages`
variable. This can also be overridden at run time using a space separated list:

    packer build -var 'apt_packages=apache2 php' marketplace-image.json

By default, the name of the resulting snapshot will be `marketplace-snapshot-`
with a UNIX timestamp appended. This can also be overridden at run time:

    packer build \
        -var 'image_name=apache-snapshot' \
        -var 'apt_packages=apache2 php' \
        marketplace-image.json

**Note:** The image validation script has been copied here from [digitalocean/marketplace-partners](https://github.com/digitalocean/marketplace-partners).
That repository is its canonical source. Make sure you are using the latest
version from that repository.

## Packer Details

Packer's [file provisioner](https://www.packer.io/docs/provisioners/file.html)
is used here to upload complete directories to the Droplet. The contents of
`files/var/` will be uploaded to `/var/`. Likewise, the contents of `files/etc/`
will be uploaded to `/etc/`. One important thing to know about the file
provisioner is that:

> The destination directory must already exist. If you need to create
> it, use a shell provisioner just prior to the file provisioner in order to
> create the directory. If the destination directory does not exist, the file
> provisioner may succeed, but it will have undefined results.

Packer's [shell provisioner](https://www.packer.io/docs/provisioners/shell.html)
is also used in this template both to run scripts from the `/scripts` directory
as well as to install the APT packages using an inline task. It's documentation
will also be valuable reading if you need to extend this template.