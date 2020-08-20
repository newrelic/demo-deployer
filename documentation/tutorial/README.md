# Tutorial

This tutorial will guide you step by step to install the minimum dependency and set your local configuration to run the deployer. 

You'll also practice how to compose a deployment configuration to deploy a specific set of resources (hosts for example) and the services to install and run on those resources.

Note, in the instructions below, there are references to `[user]` and a `$HOME` path.
The user is your typical user name on your local machine. 
`$HOME` similarly is where your user profile is stored on your machine. On MacOS this is typically `/Users/[user]`, on Linux `/home/[user]` and windows `C:\Users\[user]`

For example, on a MacOS machine your local user home path is written as `/Users/jsmith` if your user name is `jsmith`.

## Step 0 - Install pre-reqs & create configs

The easiest way to use the deployer, is to run it through docker.
Once docker is installed, the next step will be to create your local user config.
Proceed with the instructions below, read them all once before executing each steps.

### Install Git, Docker & Build the Deployer
* Ensure Git is installed locally on your machine by running `git version` in a shell command. If you don't see an output like `git version 2.17.1`, download and install Git from [https://git-scm.com/downloads](https://git-scm.com/downloads).
* Clone the deployer repository locally and place it into your local home user folder:
`git clone git@github.com:newrelic/demo-deployer.git $HOME/deployer`
* Create a `/configs` directory in your home folder. You'll be storing your own configuration files in this folder and those will be exposed to the docker process running the deployer. `mkdir $HOME/configs`
* Install docker by following the steps documented at [Install Docker](../docker/install/README.md)
* Build the docker image with:
```bash 
docker build -t deployer .
``` 

### Create your configuration files
* Create your local user config file by following the steps at [User Config](../user_config/README.md). You'll want to create your AWS credentials, NewRelic and a Git access token. 
* Important, for the AWS credentials, you'll need a .pem key file. Name this file in the format `[user][region].pem`. The `region` will be the region you chose while setting up your .pem key, for example `UsWest2` is an AWS region. Store your .pem key file in `$HOME/configs/[user][region].pem`
* Store your local user config file at `$HOME/configs/[user].docker.local.json`. You'll use that file when running the deployer

## Step 1 - Deploy a single `Hello` application on AWS

Follow the steps on the [Hello User Story](user_stories/Hello/README.md) to deploy the single `Hello` application onto AWS.

Once `Hello` is deployed, login to NewRelic and see the application reporting into APM, and the host data reporting into Infrastructure. You can search for all the `Hello` entities using the URL https://one.newrelic.com/redirect/search/Hello

