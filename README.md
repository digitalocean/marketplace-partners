# Osmosis Droplet Image Creation

This document will explain all the steps needed to create an Osmosis golden image through packer for distribtuion on the DigitalOcean Marketplace.

First, you must create a personal access token on DigitalOcean. This is done by selecting "API" under "Manage" in the left-most navigation menu. Next, select "Generate New Token", add any token name, expiration, give read and write scopes, then select "Generate Token". You will then be presented with your token. Ensure you keep this token safe as it can not be shown again. At this point, export your token as an environment variable will the following (replaced with your token)

```
export DIGITALOCEAN_TOKEN=dop_v1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Next, clone this repo and move inside of it:

```
cd $HOME
git clone https://github.com/czarcas7ic/osmosis-packer.git
cd $HOME/osmosis-packer
```

If do not already have packer installed, do so with the following:

Mac
```
brew install packer
```

Ubuntu
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

There should be only one variable that needs to get changed for each release and that is the "application_version" under "variables" in the marketplace-image.json. For example, if this value says "v7.2.0", it will pull and build the "v7.2.0" tag from the osmosis repo. If in the future an external dependency changes (lets say we move from go 1.17 to 1.18), this can be modified in the "01-osmosis.sh" file under the "scripts" folder.

Once the value has been changed to the next version and you have your DIGITALOCEAN_TOKEN exported as you did earlier, the following command will spin up a node, install decencies, clean and prep for a snapshot to be taken, power down the VM, then take a snapshot:

```
packer build marketplace-image.json
```

Once complete (usually 10-15 minutes) you will see a success message in your terminal as well as your final image in "Images" under the "Manage" section in the left-most menu on the DigitalOcean website.

This image can then be used to submit to the Marketplace through the vendor portal!
