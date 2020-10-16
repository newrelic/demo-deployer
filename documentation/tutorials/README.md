# Tutorials

To help you see the power of the `demo-deployer`, we've provided a set of tutorials, in the form of user stories. Each story spins up and instruments infrastructure for your hands-on exploration.

Before you begin, you'll install the minimum dependencies for all stories and set your local configuration to run the deployer.

> **Note:** In the instructions below, there are references to `[user]` and a `$HOME` path. The user is your typical user name on your local machine. `$HOME` is where your user profile is stored on your machine. On MacOS, this is typically `/Users/[user]`. On Linux, `/home/[user]`. On Windows, `C:\Users\[user]`.
>
> For example, on a MacOS machine, your local user home path is written as `/Users/jsmith`, if your user name is `jsmith`.

## Getting started

Before you walk through a story, you need to install the required dependencies, build your Docker image, and create your local user configuration file.

### Install Git

Ensure Git is installed on your machine:

```console
$ git version
git version 2.28.0
```

 If you don't see similar output, [download and install Git](https://git-scm.com/downloads).

 ### Install Docker and build the deployer image

 [Install Docker](../docker/install/README.md) and clone the `demo-deployer` repository:

```console
$ git clone https://github.com/newrelic/demo-deployer.git
```

Then, navigate to the deployer directory and build the container:

```console
$ cd demo-deployer
$ docker build -t deployer .
```

### Create your configuration files

Create a directory in your home folder called `configs`:

```console
$ mkdir $HOME/configs
```

You'll store your configuration files in this folder and expose it to the docker process running the deployer.

Next, [create your local user config file](../user_config/README.md). For most stories, you need to create AWS and NewRelic credentials.

> **Important!** For the AWS credentials, you need a .pem key file. Name this file in the format `[user][region].pem`. The `region` is the pascal-cased region you chose while setting up your .pem key. For example, `UsWest2` if you selected `us-west-2`. Store your .pem key file in `$HOME/configs/[user][region].pem`

Finally, store your local user config file at `$HOME/configs/[user].docker.local.json`. You use that file when you run the deployer.

## User Stories

Great! Now that you've set up your environment, choose a story to walk through to learn more about the deployer and New Relic:

- [Hello](Hello/README.md): Spin up your first application!
- [Acme Telco Lite](AcmeTelcoLite/README.md): An in-depth look at using New Relic to discover the sources of various issues in a microservice architecture.