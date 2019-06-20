# Getting Started with Marketplace Images

The overall process for creating a Marketplace image is as follows:

1. **Create and configure a build Droplet manually first** to make sure your configuration works. You can create a build Droplet with any method, like the [control panel](https://cloud.digitalocean.com/), the [API](https://developers.digitalocean.com/), or command-line tools like [`doctl`](https://github.com/digitalocean/doctl).

2. **Clean up and validate the build Droplet with the provided scripts**, `cleanup.sh` and `img_check.sh`. The scripts will check for and fix potential security concerns and verify that the image will be compatible with Marketplace.

3. **Take a [snapshot](https://www.digitalocean.com/docs/images/snapshots/) of the build Droplet** after you power it down, then test the resulting image. While there are several ways to create an image, we recommend snapshots as the most simple and consistent option.

4. **Automate your build** for replicable and configurable processes with minimal additional effort. We provide some Fabric and Packer templates to get you started.

5. **Submit your final image** to the Marketplace team for review.

## Image Requirements

DigitalOcean Marketplace images must use a supported Linux distribution and must include some required software packages.

### Supported Operating Systems

To maintain compatibility with Marketplace tools and processes, we support a limited number of Linux distributions and releases for Marketplace images. These options provide either `deb`- or `rpm`-based packaging and will have security patches and updates for a reasonable time period.

We currently support the following OSes:

- Debian 9 (stretch)
- Ubuntu 18.04 (LTS)
- Ubuntu 16.04 (LTS)
- CentOS 7.x
- CentOS 6.x

All supported operating systems are available as base images to build on in the DigitalOcean cloud.

### Required Software Packages

The following software packages are necessary for the initial configuration of new Droplets and to ensure connectivity:

- `cloud-init` 0.76 or higher (0.79 or higher recommended)
- `openssh-server` (SFTP-enabled configuration recommended)

 All of these packages are provided by default in the default DigitalOcean base images.

## Image Configuration

### Running Commands on First Boot

You can often pre-load much of what your image will need in your build system, but some setup (like setting database passwords or configuration that needs the Droplet's assigned IP address) will need to be run for each new Droplet created from your image.

You can create scripts that run on first boot using cloud-init. Droplets will attempt to run any scripts located in the `/var/lib/cloud/scripts/per-instance` directory when they're first created. Scripts in that directory are run in alphanumerical order, so we recommend using a number as the beginning of the file names (e.g. `01-example-script.sh`).

Make sure you can run the script from the command line successfully and that it has execute permissions.

### Running Commands on First Login

Some of your image setup may require information that you can't get automatically, like the domain name to use for a service. You may also need to run interactive third-party scripts, like LetsEncrypt's Certbot.

To run a script on the user's first login, we recommend adding a line to the root `.bashrc` file that runs the script and adding a line to the script that removes the line from the root `.bashrc` file.

More specifically, at the end of the script you want to run on first login, add the following line. For consistency, we recommend putting first login scripts in the `/opt/your_company_name` directory. Make sure the script has execute permissions.

```
cp -f /etc/skel/.bashrc /root/.bashrc
```

Then add a line to the end of `/root/.bashrc` that runs your script by specifying the full path to the script.

When the user first logs in, the system runs `.bashrc`, which will automatically run your script. The last line of the script overwrites the root `.bashrc` with the default `.bashrc` from the `/etc/skel` directory so the call to run your script no longer exists. Using this method, your script only runs once the first time the user logs in, but the file remains in the filesystem if they need to re-run or reference it later.

### Recommendations

* **Use [snapshots](https://www.digitalocean.com/docs/images/snapshots/) to create the image**.

  There are several ways to create an image from your build Droplet, but snapshots are the most consistent and simple option for Marketplace. For example, Droplets created using [custom images](https://www.digitalocean.com/docs/images/custom-images/) will not be able to use some features including automatic IPv6 assignment.

* **Use the smallest suitable disk size**.

  We don't support decreasing the size of a Droplet's disk because it poses data integrity issues. Building your image using the smallest disk size appropriate for your use case lets your users choose from the widest variety of Droplet plans.

* **Do not enable unnecessary DigitalOcean features on your build Droplet**.

  By not enabling features like monitoring, IPv6, or private networking when you create your build Droplet, you retain more of your distribution's standard configuration, meaning you'll need to do less cleanup before you create the final image.

* **Install software updates from the distribution's repositories** before creating your final image.

  This secures the system and can save your users time when they create new Droplets from your image.

* **Use official package repositories** or well-maintained third-party repositories whenever possible. Packages installed through other means may not provide a mechanism for applying timely security updates.

  For official distribution packages, we recommend maintaining the `mirrors.digitalocean.com` mirrors, which are direct mirrors of the distribution's package archive. These mirrors are provided by default and provide faster downloads because the mirrors are stored within our infrastructure.
  
* **Add a message of the day (MOTD)**, which is text displayed when a user logs into their Droplet. We recommend writing an MOTD which introduces your image's features and points users to its documentation.
  
  You can add an MOTD to your image by creating a text file in `/etc/update-motd.d`. Naming the file beginning with `99`, like `99-image-readme`, will display the MOTD as the last text the user sees before the login prompt.

## Cleaning Up the Build Droplet

You can make sure you get a clean image from your build Droplet by running [`cleanup.sh`](marketplace_validation/cleanup.sh) after setup.

This script does several things:

- Deletes bash history so commands you ran during the build process are not stored in the image.
- Cleans up the package manager's database.
- Truncates or removes unneeded log files.
- Removes SSH keys from the root user. If your build Droplet has other user accounts, you should remove SSH keys from them as well.
>  :warning: Note: If you have password access disabled and you remove SSH keys, you won't be able to log into the Droplet, so make sure you're ready to create your image before running this script.
- Removes the cloud-init instance information so the image will run your first boot scripts and use the cloud-init service on first boot for things like networking.

`cleanup.sh` is meant for Ubuntu, but if you're using a distribution like CentOS, you can run similar commands.

## Verifying the Build Droplet

Once you've finished configuring your build Droplet, verify it by running [`img_check.sh`](marketplace_validation/img_check.sh) to make sure it's is compatible with Marketplace. This script looks for security and cleanup concerns that you should address before creating your final image.

More specifically, `img_check.sh` images against the following criteria:

- Uses a [supported distribution and release](#supported-operating-systems)
- All security updates are installed
- Packages are updated
- A firewall is installed and configured
- Uses a valid version of cloud-init
- Doesn't have SSH keys, preset passwords, populated log files/archives, or `bash_history`

`img_check.sh` is designed to be minimally invasive and avoid changes to disk, with the exception that it will update APT and yum package databases to look for uninstalled security updates. You can use `img_check.sh` from within an image build system before you create the image itself.

## Creating and Submitting the Image

When your build Droplet is configured and verified, the final step is to create the image. There are several ways to create images, like exporting a disk image from [VirtualBox](https://www.virtualbox.org/), [VMware](https://www.vmware.com/), or a physical machine.

If you're using a build Droplet, we recommend creating a snapshot as the most consistent and simple method of creating an image. The [snapshot creation documentation](https://www.digitalocean.com/docs/images/snapshots/how-to/snapshot-droplets/) has a detailed walkthrough of the process, but in brief:

1. **Power down the build Droplet**. You can do this by running `shutdown -h now` manually or by [using the API to power the Droplet down](https://developers.digitalocean.com/documentation/v2/#shutdown-a-droplet).

>   :warning: Note: The live snapshot feature lets you take an image of your Droplet's disk while the Droplet is still powered on, but you should always power down your Droplet when creating an image for Marketplace.

2. **Take the snapshot**. You can do this from the control panel in the Droplet's **Snapshots** tab or by [using the API to snapshot the Droplet](https://developers.digitalocean.com/documentation/v2/#snapshot-a-droplet).

You can submit your image to the Marketplace team for review by providing the snapshot name or ID. You can use `doctl compute snapshot list` or `doctl compute image list-user` to get this information. [Learn more about using `doctl` with snapshots](https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client#working-with-snapshots).

## Automating your Build

Manually creating a Marketplace image is a good way to get started, and while you can submit a final image created this way, we recommend a scripted process to ensure replicable and configurable builds. There are many tools available to automate the creation and configuration of your build Droplet.

[Fabric](http://www.fabfile.org/index.html) is a Python library designed to execute shell commands remotely over SSH. [Packer](https://www.packer.io/intro/index.html) is a tool for creating images from a single source configuration. Both are good options to script the creation of your build Droplet, which you can then snapshot to create a new Marketplace-ready image.

We provide [a Fabric template and documentation](fabric) as well as [a Packer template and documentation](packer) to help you get started with build automation.
