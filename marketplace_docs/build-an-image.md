# Building Marketplace Images Manually

Marketplace images can be built manually and this is a recommended first step to ensure your configuration will work as expected.  While it is possible to submit a final image that was created with these methods we recommend the use of a scripted build process over a manual one to ensure it can be repeated, revised, and reviewed with minimal additional effort.

In order to submit an image to the DigitalOcean Marketplace your image must include some prerequisites and be built on an approved Linux distribution.

## Supported Operating Systems

To ensure compatibility with Marketplace tools and processes we currently support a limited number of Linux distributions and releases.  These operating systems are all available as a base to build on in the DigitalOcean cloud.

The following operating systems may be used as the base for your marketplace image. The options provide for either deb or rpm based packaging and are versions for which security patches and updates will be provided for a reasonable time period.

* Ubuntu 18.04 (LTS)
* Ubuntu 16.04 (LTS)
* CentOS 7.x
* CentOS 6.x

### Prerequisites
To ensure that your image will work properly on the DigitalOcean cloud you must ensure some software is included in your image.  These software packages are necessary for the initial configuration of new droplets and to ensure connectivity.  All of the items listed are provided by default in the default DigitalOcean base images. 

* cloud-init 0.76 or higher (0.79 or higher recommended)
* openssh-server (sftp enabled configuration recommended)

## Building your Image
While DigitalOcean offers a "custom image" tool allowing you to import your own disk images this feature is currently limited and droplets created using imported images will not be able to use some features including automatic ipv6 assignment.  For this reason we recommend using a snapshot image of a build droplet to create your Marketplace image.

### Creating your build droplet
You may create your build droplet from the cloud control panel, using the API or by using doctl, the DigitalOcean command line tool.  When creating your build droplet please keep in mind the following:

#### Use the smallest possible droplet size for your software.
Because shrinking disk images can result in data loss, DigitalOcean does not support this option.  Building your image using the smallest droplet size will ensure it can be used with any droplet plan.

#### Use only one of the supported distribution versions
To ensure your image can be reviewed and added to the Marketplace in a timely manner and without major revisions, start with a droplet running one of the supported distributions and versions.

#### Use an SSH Key
We strongly recommend using an ssh key for authentication on your build server.  The key can easily be removed prior to creating your snapshot and ensures the default configuration will work best with the DigitalOcean cloud.

#### Do not use any other features for your build droplet
It is recommended that you not enable other features when creating your build droplet. This includes monitoring, ipv6, private networking, or block storage volumes. By doing this you will retain more of you distribution's standard configuration and have less clean-up needed to prepare your droplet to create your image.

### Installing Software on your Build Droplet
One of the first tasks you will likely undertake will be to install additional software that is required for your final image.  Whenever possible you should use software installed from the official package repositories or add third party repositories which provide regular updates.  Packages installed through other means may not provide a mechanism to ensure security updates are applied as needed.  For official distribution packages, we recommend maintaining the *mirrors.digitalocean.com* mirrors which are provided by default.  These repositories are direct mirrors of the distribution's package archive stored within DigitalOcean's infrastructure.  Continuing to use these repositories will ensure faster downloads of distribution packages for your users.

**NOTE:** Be sure to install any software updates available from the distribution's repositories prior to creating your snapshot image.  This helps ensure a secure distribution and can save your users time when they create a new droplet from your image.

### Running commands on First Boot
While you can usually pre-load much of what your image will need on your build system, some functions including setting passwords for services included in the image or using the assigned IP address for configuration should be run for each new droplet created from your image.  

Cloud-init can handle this for us.  The directory `/var/lib/cloud/scripts/per-once` is checked when a new droplet using your image is launched and will attempt to run any scripts located there.  Scripts in this directory are run in alpha-numerical order so using a number as the beginning of your filename is recommended *(ex. 01-myscript.sh)*.  Be sure that your script can be run from the command line and that it has execute permissions `chmod +x 01-myscript.sh`.

### Running commands or interactive scripts on first-login
Sometimes you may require information that can not be obtained automatically such as the domain name to use for a service.  You may also need to run interactive third party scripts like LetsEncrypt's certbot.  This is not quite as simple as first-boot scripts but can be accomplished with a little custom work.

* Create a bash script to run your commands or prompt for information and place that script in `/opt/companyname/script_name.sh` and give the script execute permissions.
* At the end of your script add the following command which will prevent it from being re-run on subsequent logins.  `cp -f /etc/skel/.bashrc /root/.bashrc`
* Edit the file `/root/.bashrc` and add a line at the end to run your script by placing the full path to your script in the file.

When a user creates a droplet using your image the following will happen:
* When the user first logs in, the .bashrc script is run and after doing it's other work it will automatically launch your script.
* After the required work is completed by your script, the line we added to it will copy the default .bashrc file from the `skel` directory to the root user's directory so the call to run your script no longer exists.

Using this method ensures that your script is only run during the first boot but remains in the filesystem if the user needs to re-run or reference it later.

### Adding a MOTD (Message of the Day)
The MOTD is text that is displayed when a user logs into a droplet created from your image.  We strongly recommend creating a short text document which introduces your image's features and points users to useful documentation.  You can add this document to your image so it will be displayed by placing it in `/etc/update-motd.d/` with a name beginning with `99` such as `99-image-readme` so it is included in the MOTD as the last displayed text prior to the login prompt.

### Cleaning up your build droplet

To ensure that your build droplet results in a clean image you can run the following script on it before creating your snapshot if you are using an Ubuntu base or run similar commands for CentOS:

```
#!/bin/bash
apt-get -y update
apt-get -y upgrade
rm -rf /tmp/* /var/tmp/*
history -c
cat /dev/null > /root/.bash_history
unset HISTFILE
apt-get -y autoremove
apt-get -y autoclean
find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
rm -rf /var/log/*.gz /var/log/*.[0-9] /var/log/*-????????
rm -rf /var/lib/cloud/instances/*
rm -f /root/.ssh/authorized_keys /etc/ssh/*key*
dd if=/dev/zero of=/zerofile; sync; rm /zerofile; sync
cat /dev/null > /var/log/lastlog; cat /dev/null > /var/log/wtmp
```

This script will do several things to clean up including:

* Delete your bash history so commands that were run during the build process are not stored in your image
* Clean up the package manager's database
* Truncate or remove log files that are not needed
* Remove the cloud-init instance information.  This step will ensure that the image will look to the cloud-init service on first boot for things like networking and also that it will run your first-boot scripts.
* Remove ssh-keys from the root user (if you used any other user account in your build droplet you should do this for them as well)

**NOTE:** Once you remove your ssh-keys you may no longer be able to log into your droplet. Ensure you are fully ready to create your snapshot before taking this step.

### Check your Image
Before creating your final snapshot, run the img_check.sh utility found in the `marketplace_validation` directory of this repository.  This script will check for any security or cleanup concerns that should be addressed prior to creating your final snapshot image.

### Creating your Snapshot Image

The final step is to take a snapshot of your build droplet.  The DigitalOcean cloud supports "live snapshots" which can take an image of your droplet's disk while the droplet is powered on.  Do not use this feature when creating your image for Marketplace.  Instead, power down your droplet either from your ssh session with `shutdown -h now` or by using the cloud control panel.  Once your droplet is powered off, the Snapshot section under your droplet in the control panel will allow you to create your snapshot and give it a name.

Once your image has been created you can submit it to the Marketplace team for review by providing the image name and/or id.