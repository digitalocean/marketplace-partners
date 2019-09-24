# Build Automation with Fabric

[Fabric](http://www.fabfile.org/index.html) is a Python library designed to execute shell commands remotely over SSH. You can use it to script the creation of your build Droplet, which you can then snapshot to create a new Marketplace-ready image.

> :warning: Make sure to read the [Getting Started guide](../getting-started.md) for fundamental information on Marketplace image requirements first.

You can install Fabric using [pip](https://pip.pypa.io/en/stable/), the Python build system, or by using your distribution's official package repository. See the [Fabric installation documentation](http://www.fabfile.org/installing.html) for more detail.

To set up your build environment, you need to create a `fabfile.py` script which uses the Fabric library to build your image. If you're familiar with Python, you can write this script yourself. If not, we provide a few resources to help you get started:

* The `template` directory contains **a Fabric project template** that you can use to automatically configure and prepare a build Droplet without writing any Python. After you add your Bash scripts and files, the Fabric script we provide configures, cleans, and powers down the specified Droplet to leave it prepared for you to snapshot.

* The `LAMP.zip` file contains **a working sample Fabric configuration** that configures, cleans, and powers down an example Droplet (based on the [LAMP One-Click](https://marketplace.digitalocean.com/apps/lamp)). This project leaves you with a LAMP-based build Droplet that is ready for you to snapshot.

## DigitalOcean's Fabric Project Template

The Fabric project template in the `template` directory lets you automatically configure and prepare a build Droplet without writing any Python.

To use it, you need to add your files and Bash scripts to the appropriate directories and specify the packages you want to install. From there, you can run a single command to fully configure an existing Droplet so it's ready for you to snapshot.

* **Files**. In the `files` directory, add any files you want to include in your image. This project will upload the files to the associated location on the build Droplet. For example, to create the file `/etc/example.txt` on the build Droplet, add it here as `files/etc/example.txt`.

* **Scripts**. In the `scripts` directory, add any scripts that install or configure install or configure your software before you create the image. This project will upload these scripts to `/tmp` on the build Droplet, give them appropriate permissions, run them, and then remove them as part of the cleanup process. Any subdirectories under `scripts` will be ignored.

* **Packages**. In `packages.txt`, include a space-separated list of packages that should be installed via `apt-get` on your build Droplet. Include all package names on a single line.

* **Configuration**. The `fabric.yaml` is used to change the default fabric configuration. `user` specifies the user account that the fabfile should use when logging into the Droplet via SSH. In most cases, it should remain **root**.

Once you've added your files and created your package list, create a Droplet to use as the build Droplet.

You can perform a test run of the build by specifying the Droplet's IP with the `testbuild` task. This will install your files and packages and run your scripts but will not clean up the system or power down the Droplet. You can use this task for testing during development.

    fab testbuild -H <your_build_droplet_ip_address>

When your build works as expected, you can fully prepare the build Droplet with the `build` task. This performs all steps: uploading files, running scripts, installing packages, cleaning the system, and powering down the Droplet to prepare it for you to snapshot.

    fab build -H <your_build_droplet_ip_address>

> :warning: For your final image build, make sure you've only run the Fabric script once before creating a snapshot.

### Quick Setup

    python3 -m venv venv
    venv/bin/pip install -U pip
    venv/bin/pip install fabric
    venv/bin/fab testbuild -H <your_build_droplet_ip_address>

### Common Issues

#### Unsupported key file

Error:

    paramiko.ssh_exception.SSHException: not a valid RSA private key file

[Fix](https://freelancing.studio/paramiko-and-rsa-key/):

    puttygen id_rsa -O private-openssh -o new.key

## Sample Fabric Configuration

The `LAMP.zip` file in this directory contains a [working sample Fabric configuration](LAMP.zip) that configures, cleans, and powers down an example Droplet (based on the [LAMP One-Click](https://marketplace.digitalocean.com/apps/lamp)). Running this example project leaves you with a LAMP-based build Droplet that is ready for you to snapshot.

>  :warning: The sample configuration uses Fabric 1.x. Fabric 1.x syntax is incompatible with Fabric 2.x, so you'll need to install [Fabric 1.x](http://www.fabfile.org/installing-1.x.html) explicitly. Fabrix 1.x is also incompatible with Python 3+, so you'll need to use [`Fabric3`](https://pypi.org/project/Fabric3/) to run Fabric 1.x with Python 3+.

The fabfile in this sample configuration comes with some variables and functions that may be useful:

* **Variables**
  * `APT_PACKAGES` contains a space-separated list of packages to install on a Debian or Ubuntu base system.
  * `env.user` specifies the user account that the fabfile should use when logging into the Droplet via SSH. In most cases, it should remain **root**.
* **Functions**
  * `build_base` runs all setup steps but skips cleanup and powering down the build Droplet. You can run this task and then SSH into the Droplet to check the environment.
  * `build_image` runs all steps of the build process, including cleanup and powering down the build Droplet. Run this function on a newly-created Droplet using the base image you're building on.
  * `clean_up` runs some common functions to clean up logs, SSH keys, and other remnants of the build process that shouldn't be a part of the final image.
  * `shutdown` sends a `shutdown -h now` command to the build Droplet to power it down. `build_image` calls this function once the build is complete so you can create a snapshot.

You can modify this Fabric configuration to become more familiar with the software or to use it as a basis for your automated build system.
