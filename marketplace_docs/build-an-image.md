# Building Marketplace Images Manually

In order to submit an image for an app listing in the DigitalOcean Marketplace, you must engineer it 
in a compatible format, using a supported operating system and with a few necessary pre-requisities, 
and finally pass the tests in the marketplace_validation _img check.sh_ script. 

This page will help you navigate the simple pre-requisites and processes. The time required to
engineer an image may vary depending on your software's needs, but in summary it'll usually be 30 to 60 
minutes of hands-on work.

## Supported operating systems and pre-requisities

### Operating systems

Currently we support a limited number of operating systems: 

* Ubuntu 18.04
* Ubuntu 16.04
* CentOS 7.x
* CentOS 6.x

### Pre-requisites

* cloud-init 0.76 or higher _(0.79 or higher recommended)_

## Building an image

There are two methods to engineer a suitable image format:

1. Snapshot - build on a supported DigitalOcean base image
2. Custom Image - build on a supported upstream base, and upload a supported format (vmdk, qcow2, etc)

_n.b. While you can engineer a Custom Image and upload it to DigitalOcean for Marketplace apps,
users of Droplets started from those images currently cannot use certain features (floating IPs, 
IPv6). **We therefore recommend using the Snapshot method until further notice.**_

### Snapshot

You can prepare your software installed in a "ready-to-configure" state on a supported DigitalOcean base 
image, and when finished with your changes and quality checks, shut it down in order to prepare a snapshot
of the Droplet in it's current state. This prepares an image ready to be submitted and be replicated 
to new Droplets started by users who find your image as a One-click app via DigitalOcean Marketplace.

Here's what you'll be doing in a nutshell:

* Start a fresh image base Droplet (5 mins)
* Install your software (5 to 60 mins)
* Run checks and clean up artifacts (10 mins)
* Shutdown and snapshot the Droplet (5 mins)

1. *Start a fresh image base Droplet.* Log into the control panel, and start a new Droplet in your 
chosen data center _at the smallest 1GB Droplet level_. Ubuntu 18.04 is the default, but you can choose 
any supported operating system. You can also start from an existing DigitalOcean One-click app, e.g., 
Docker or LEMP, as these are all supported already.

2. *Install your software*. Here's a few sample steps you might follow:

  1. Once the Droplet has started up, copy the IP address and log into the root shell with either your 
password or SSH keys (depending on the options you chose when starting).
  2. Directly install the packages and dependencies for your software. For example, if you've built an 
installer for your users to test drive your software quickly, you may be able to run it to install all 
the necessary bits _providing configuration can be left for when the user boots the image on a new 
Droplet_.
  3. OR, install the scripts that will install your software live, in real-time, once the user starts your
One-click app on a new Droplet. For example, if you've built a script that prepares the environment,
downloads the latest version of your software and installs it, and then starts interactive user configuration
– then you can use the script to do these things as each user starts your app. 

N.B. bear in mind the time taken by such steps after boot or login, and try to keep long times to a minimum: you could 
include the necessary package versions on the local filesystem ready to install, for example.

In order to use a scripted live install, you'll want to follow a simple best practice:

    1. Create a folder for your script under /opt/yourvendorname
    2. Add your shell script there
    3. Call your shell script on login by adding it to the /root/.bashrc before snapshotting
    4. Make sure you copy a clean .bashrc to /root/.bashrc as the last cleanup step in your script

    e.g., `cp -f /etc/skel/.bashrc /root/.bashrc`

3. Run cleanup steps 

<tbd document and add a sample script of the cleanup steps from the fabfile template>

4. MOTD

<tbd document and add a sample MOTD, removing things like "Welcome to the DigitalOcean appname One-click">